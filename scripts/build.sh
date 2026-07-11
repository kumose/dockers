#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REGISTRY="${REGISTRY:-}"
IMAGE_PREFIX="${IMAGE_PREFIX:-kumo}"

# name -> base image mapping
declare -A BASE_IMAGE
BASE_IMAGE[ubuntu20]="ubuntu:20.04"
BASE_IMAGE[ubuntu22]="ubuntu:22.04"
BASE_IMAGE[ubuntu24]="ubuntu:24.04"
BASE_IMAGE[debian11]="debian:11-slim"
BASE_IMAGE[debian12]="debian:12-slim"
BASE_IMAGE[alpine319]="alpine:3.19"
BASE_IMAGE[alpine320]="alpine:3.20"
BASE_IMAGE[centos9]="quay.io/centos/centos:stream9"

ALL_NAMES=(ubuntu20 ubuntu22 ubuntu24 debian11 debian12 alpine319 alpine320 centos9)

usage() {
    echo "Usage: $0 [options] <name> <arch>"
    echo ""
    echo "Options:"
    echo "  --push      Push image to registry with version + latest tags"
    echo "  --list      List available names"
    echo ""
    echo "Environment:"
    echo "  REGISTRY       Registry host (required when --push)"
    echo "  IMAGE_PREFIX   Image name prefix (default: kumo)"
    echo ""
    echo "Examples:"
    echo "  $0 ubuntu24 amd64"
    echo "  REGISTRY=ghcr.io/kumose $0 --push ubuntu24 amd64"
    exit 1
}

build_image() {
    local name="$1"
    local arch="$2"
    local push="${3:-false}"

    local base="${BASE_IMAGE[$name]:-}"
    if [[ -z "$base" ]]; then
        echo "error: unknown image name '$name'"
        exit 1
    fi

    local dockerfile="$REPO_ROOT/$name/Dockerfile"
    if [[ ! -f "$dockerfile" ]]; then
        echo "error: Dockerfile not found at $dockerfile"
        exit 1
    fi

    local version_file="$REPO_ROOT/$name/VERSION"
    local version
    if [[ -f "$version_file" ]]; then
        version=$(cat "$version_file" | tr -d ' \t\n')
    else
        version="0.0.0"
    fi

    local tag="${IMAGE_PREFIX}-${name}-${arch}"
    local platform="linux/${arch}"

    if [[ "$push" == "true" ]]; then
        local registry_tag="${REGISTRY}/${tag}"

        echo "=== Building $registry_tag:$version ($platform) ==="

        docker buildx build --platform "$platform" \
            -t "${registry_tag}:${version}" \
            -t "${registry_tag}:latest" \
            -f "$dockerfile" \
            "$REPO_ROOT/$name" \
            --push

        echo "=== Pushed: ${registry_tag}:${version} / ${registry_tag}:latest ==="
    else
        echo "=== Building $tag ($platform) v$version ==="

        docker buildx build --platform "$platform" \
            -t "${tag}" \
            -f "$dockerfile" \
            "$REPO_ROOT/$name" \
            --load

        echo "=== Built: $tag ==="
    fi
}

build_all() {
    local push="${1:-false}"
    for name in "${ALL_NAMES[@]}"; do
        for arch in amd64 arm64; do
            build_image "$name" "$arch" "$push"
        done
    done
}

if [[ $# -eq 0 ]]; then
    usage
fi

PUSH=false
POSITIONAL=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)
            BUILD_ALL=true
            shift
            ;;
        --push)
            PUSH=true
            shift
            ;;
        --list)
            for n in "${ALL_NAMES[@]}"; do echo "$n"; done
            exit 0
            ;;
        --help|-h)
            usage
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

if [[ "${BUILD_ALL:-false}" == "true" ]]; then
    build_all "$PUSH"
elif [[ ${#POSITIONAL[@]} -eq 2 ]]; then
    build_image "${POSITIONAL[0]}" "${POSITIONAL[1]}" "$PUSH"
else
    usage
fi
