FROM quay.io/centos/centos:stream9

ARG TARGETARCH

RUN dnf install -y \
        dnf-plugins-core \
        epel-release \
    && /usr/bin/crb enable \
    && dnf install -y \
        gcc-c++ \
        curl \
        git \
        python3 \
        python3-pip \
        ninja-build \
        make \
        autoconf \
        libtool \
        pkgconfig \
        openssl-devel \
        zip \
        unzip \
        ca-certificates \
    && dnf clean all

RUN case "${TARGETARCH}" in \
        amd64) CMAKE_ARCH="x86_64" ;; \
        arm64) CMAKE_ARCH="aarch64" ;; \
        *) echo "unsupported arch: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/Kitware/CMake/releases/download/v3.31.10/cmake-3.31.10-linux-${CMAKE_ARCH}.tar.gz" | \
    tar xz --strip-components=1 -C /usr/local && \
    cmake --version
