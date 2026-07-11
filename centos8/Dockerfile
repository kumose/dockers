FROM centos:8

ARG TARGETARCH

# Fix EOL repos: centos 8 went EOL December 2021
RUN sed -i 's|mirror.centos.org|vault.centos.org|g; s|^#baseurl|baseurl|; s|^mirrorlist|#mirrorlist|' /etc/yum.repos.d/*.repo

# EPEL + tools (gcc 8.5 can compile cmake 3.31)
# curl-minimal is pre-installed on centos:8, installing curl conflicts
RUN dnf install -y epel-release && \
    dnf install -y gcc-c++ git python38 python38-pip make autoconf libtool pkgconfig openssl-devel perl perl-IPC-Cmd kernel-headers zip unzip ca-certificates && \
    dnf clean all

# python38 provides python3.8, not python3
RUN ln -sf /usr/bin/python3.8 /usr/bin/python3 && \
    ln -sf /usr/bin/pip3.8 /usr/bin/pip3

# Build cmake 3.31.10 from source
RUN curl -fsSL "https://github.com/Kitware/CMake/releases/download/v3.31.10/cmake-3.31.10.tar.gz" | \
    tar xz -C /tmp && \
    cd /tmp/cmake-3.31.10 && \
    ./bootstrap --prefix=/usr/local && \
    make -j$(nproc) && \
    make install && \
    rm -rf /tmp/cmake-3.31.10

# Build ninja 1.13.1 from source
RUN git clone --depth 1 -b v1.13.1 https://github.com/ninja-build/ninja.git /tmp/ninja && \
    cmake -S /tmp/ninja -B /tmp/ninja-build -DCMAKE_BUILD_TYPE=Release && \
    cmake --build /tmp/ninja-build --parallel && \
    cp /tmp/ninja-build/ninja /usr/local/bin/ && \
    rm -rf /tmp/ninja /tmp/ninja-build
