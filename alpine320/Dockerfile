FROM alpine:3.20

ARG TARGETARCH

RUN apk add --no-cache \
        build-base \
        linux-headers \
        curl \
        git \
        python3 \
        py3-pip \
        make \
        autoconf \
        libtool \
        pkgconfig \
        openssl-dev \
        zip \
        unzip \
        ca-certificates

RUN curl -fsSL "https://github.com/Kitware/CMake/releases/download/v3.31.10/cmake-3.31.10.tar.gz" | \
    tar xz -C /tmp && \
    cd /tmp/cmake-3.31.10 && \
    ./bootstrap --prefix=/usr/local && \
    make -j$(nproc) && \
    make install && \
    rm -rf /tmp/cmake-3.31.10

RUN git clone --depth 1 -b v1.13.1 https://github.com/ninja-build/ninja.git /tmp/ninja && \
    cmake -S /tmp/ninja -B /tmp/ninja-build -DCMAKE_BUILD_TYPE=Release && \
    cmake --build /tmp/ninja-build --parallel && \
    cp /tmp/ninja-build/ninja /usr/local/bin/ && \
    rm -rf /tmp/ninja /tmp/ninja-build
