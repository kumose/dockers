FROM quay.io/centos/centos:stream9

ARG TARGETARCH

RUN dnf install -y dnf-plugins-core epel-release
RUN /usr/bin/crb enable
RUN dnf install -y gcc-c++ git make autoconf libtool
RUN dnf install -y python3 python3-pip
RUN dnf install -y ninja-build
RUN dnf install -y curl openssl-devel pkgconfig zip unzip ca-certificates
RUN dnf clean all

RUN case "${TARGETARCH}" in \
        amd64) CMAKE_ARCH="x86_64" ;; \
        arm64) CMAKE_ARCH="aarch64" ;; \
        *) echo "unsupported arch: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/Kitware/CMake/releases/download/v3.31.10/cmake-3.31.10-linux-${CMAKE_ARCH}.tar.gz" | \
    tar xz --strip-components=1 -C /usr/local && \
    cmake --version
