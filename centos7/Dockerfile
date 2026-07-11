FROM centos:7

ARG TARGETARCH

# Fix EOL repos: centos 7 went EOL June 2024
RUN sed -i 's|mirror.centos.org|vault.centos.org|g; s|^#baseurl|baseurl|; s|^mirrorlist|#mirrorlist|' /etc/yum.repos.d/*.repo

# devtoolset-11: gcc 11 (system gcc 4.8 is too old for cmake 3.31)
# centos-release-scl installs new .repo files, fix them to vault too
RUN yum install -y centos-release-scl && \
    sed -i 's|mirror.centos.org|vault.centos.org|g; s|^#baseurl|baseurl|; s|^mirrorlist|#mirrorlist|' /etc/yum.repos.d/*.repo && \
    yum install -y devtoolset-11-gcc devtoolset-11-gcc-c++ && \
    yum clean all
ENV PATH=/opt/rh/devtoolset-11/root/usr/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/rh/devtoolset-11/root/usr/lib64:/opt/rh/devtoolset-11/root/usr/lib

# EPEL + base tools
RUN yum install -y epel-release && \
    yum install -y curl git python38 python38-pip make autoconf libtool pkgconfig openssl-devel zip unzip ca-certificates && \
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
