FROM debian:11-slim

ARG TARGETARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        perl \
        curl \
        git \
        python3 \
        python3-pip \
        ninja-build \
        make \
        autoconf \
        libtool \
        pkg-config \
        libssl-dev \
        linux-libc-dev \
        zip \
        unzip \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN case "${TARGETARCH}" in \
        amd64) CMAKE_ARCH="x86_64" ;; \
        arm64) CMAKE_ARCH="aarch64" ;; \
        *) echo "unsupported arch: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/Kitware/CMake/releases/download/v3.31.10/cmake-3.31.10-linux-${CMAKE_ARCH}.tar.gz" | \
    tar xz --strip-components=1 -C /usr/local && \
    cmake --version
