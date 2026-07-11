FROM centos:7

ARG TARGETARCH

# Fix EOL repos: centos 7 went EOL June 2024
RUN sed -i 's|mirror.centos.org|vault.centos.org|g; s|^#baseurl|baseurl|; s|^mirrorlist|#mirrorlist|' /etc/yum.repos.d/*.repo

# devtoolset-9: gcc 9 (system gcc 4.8 is too old for cmake 3.31)
# vault paths differ per arch: x86_64 at /centos/7/sclo, aarch64 at /altarch/7/sclo
RUN yum install -y centos-release-scl && \
    if [ "$TARGETARCH" = "amd64" ]; then \
        SCL_BASE="https://vault.centos.org/centos/7/sclo/\$basearch"; \
    else \
        SCL_BASE="https://vault.centos.org/altarch/7/sclo/\$basearch"; \
    fi; \
    printf '[centos-sclo-sclo]\nname=CentOS-7 - SCLo scl\nbaseurl=%s/sclo/\ngpgcheck=0\nenabled=1\n' "$SCL_BASE" > /etc/yum.repos.d/CentOS-SCLo-scl.repo && \
    printf '[centos-sclo-sclo-rh]\nname=CentOS-7 - SCLo scl-rh\nbaseurl=%s/rh/\ngpgcheck=0\nenabled=1\n' "$SCL_BASE" > /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo && \
    yum install -y devtoolset-9-gcc devtoolset-9-gcc-c++ && \
    yum clean all

ENV PATH=/opt/rh/devtoolset-9/root/usr/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/rh/devtoolset-9/root/usr/lib64:/opt/rh/devtoolset-9/root/usr/lib

# EPEL + base tools
RUN yum install -y epel-release && \
    yum install -y curl git python38 python38-pip make autoconf libtool pkgconfig openssl-devel perl perl-IPC-Cmd kernel-headers zip unzip ca-certificates && \
    yum clean all

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
