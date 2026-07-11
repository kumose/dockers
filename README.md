# kumo-dockers

A matrix of Docker images for Linux CI/CD testing across multiple distributions and architectures.

## Motivation

Different Linux distributions ship different versions of glibc, libstdc++, cmake, ninja, and other build tools. To ensure cross-distribution compatibility, this repository provides a set of Docker images covering the major Linux ecosystems:

- **Ubuntu** — glibc, apt, mainstream desktop/server
- **Debian** — glibc, apt, conservative/stable
- **Alpine** — musl libc, apk, minimal footprint
- **CentOS Stream** — glibc, dnf, RHEL ecosystem

Each image is built for both `amd64` and `arm64` architectures.

## Image Naming

All images are published under the `kumo-` namespace:

```
kumo-<distro><version>-<arch>
```

Examples: `kumo-ubuntu24-amd64`, `kumo-alpine320-arm64`, `kumo-centos9-amd64`.

Each image is tagged with both `<version>` and `latest` when pushed.

## Repository Structure

```
dockers/
├── .github/workflows/docker.yml    # CI: auto-detect changes, manual push
├── README.md                       # This file
├── README_CN.md                    # Chinese version
├── scripts/
│   └── build.sh                    # Build + push script
├── <distro><version>/              # e.g. ubuntu24, debian12, alpine320
│   ├── Dockerfile                  # Multi-arch (uses TARGETARCH)
│   └── VERSION                     # Semantic version of this image
└── ...
```

## Versioning

Each system directory has its own `VERSION` file containing a semver string (e.g. `1.0.0`). When pushing, images are tagged with both the version number and `latest`.

To release a new version of an image:
1. Update the `VERSION` file (e.g. `1.0.0` → `1.1.0`)
2. Commit and push to `master`
3. Go to GitHub Actions → `Build Docker Images` → `Run workflow` → select `auto` + check `Push`

## Planned Images

| Image Name                  | Base Distribution          | libc    | Version |
|-----------------------------|----------------------------|---------|---------|
| `kumo-ubuntu20-{amd64,arm64}` | Ubuntu 20.04 (Focal)     | glibc   | 1.0.0   |
| `kumo-ubuntu22-{amd64,arm64}` | Ubuntu 22.04 (Jammy)     | glibc   | 1.0.0   |
| `kumo-ubuntu24-{amd64,arm64}` | Ubuntu 24.04 (Noble)     | glibc   | 1.0.0   |
| `kumo-debian11-{amd64,arm64}` | Debian 11 (Bullseye)     | glibc   | 1.0.0   |
| `kumo-debian12-{amd64,arm64}` | Debian 12 (Bookworm)     | glibc   | 1.0.0   |
| `kumo-alpine319-{amd64,arm64}`| Alpine 3.19              | musl    | 1.0.0   |
| `kumo-alpine320-{amd64,arm64}`| Alpine 3.20              | musl    | 1.0.0   |
| `kumo-centos9-{amd64,arm64}`  | CentOS Stream 9          | glibc   | 1.0.0   |

## Usage

### Build (local verify)

```bash
./scripts/build.sh <name> <arch>
```

Examples:

```bash
./scripts/build.sh ubuntu24 amd64
./scripts/build.sh ubuntu24 arm64
```

### Build and push

```bash
REGISTRY=ghcr.io/kumose ./scripts/build.sh --push ubuntu24 amd64
```

## CI Behavior

| Trigger | Action | Push? |
|---------|--------|-------|
| Push to `master` (Dockerfile/VERSION change) | Build only changed systems | No |
| Pull request | Build only changed systems | No |
| `workflow_dispatch` + `auto` | Build systems changed in last commit | No |
| `workflow_dispatch` + `auto` + `push=true` | Build changed systems + push | Yes |
| `workflow_dispatch` + specific name | Build that system only | Based on push flag |
| `workflow_dispatch` + specific name + `push=true` | Build and push that system | Yes |

## CI Integration

These images are designed to be used in GitHub Actions with a strategy matrix. Example:

```yaml
- name: Pull image
  run: docker pull ghcr.io/kumose/kumo-ubuntu24-amd64:1.0.0

- name: Run tests in container
  run: |
    docker run --rm ghcr.io/kumose/kumo-ubuntu24-amd64:latest ./run-tests.sh
```

## License

MIT
