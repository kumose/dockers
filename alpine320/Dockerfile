FROM alpine:3.20

ARG TARGETARCH

RUN apk add --no-cache \
        build-base \
        curl \
        git \
        python3 \
        py3-pip \
        ninja \
        make \
        autoconf \
        libtool \
        pkgconfig \
        openssl-dev \
        zip \
        unzip \
        ca-certificates

RUN pip3 install --break-system-packages cmake==3.31.10 && \
    cmake --version
