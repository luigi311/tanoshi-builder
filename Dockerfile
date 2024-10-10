FROM debian:bookworm-slim AS chef 
ARG TARGETPLATFORM
ARG BUILDPLATFORM

ENV LD_LIBRARY_PATH="/usr/local/lib:/usr/lib:/lib"
ENV PATH="$PATH:/root/.cargo/bin:/root/dart-sdk/bin"


RUN apt-get update && \
    apt-get install -y \
        libssl-dev \
        build-essential \
        cmake \
        llvm \
        clang \
        libicu-dev \
        nettle-dev \
        libarchive-dev \
        libacl1-dev \
        liblzma-dev \
        libzstd-dev \
        liblz4-dev \
        libbz2-dev \
        zlib1g-dev \
        libxml2-dev \
        unzip \
        wget \
        curl \
        libwebkit2gtk-4.1-dev \
        libgtk-3-dev \
        patchelf \
        librsvg2-dev\
        libpango1.0-dev \
        libsoup-3.0-dev \
        libjavascriptcoregtk-4.1-dev \
        libb2-dev \
        binaryen && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain 1.79.0 && \ 
    rustup target add wasm32-unknown-unknown

WORKDIR /root

ENV DART_SDK_VERSION="3.5.3"
RUN DART_ARCH=$(echo $TARGETPLATFORM | sed 's/\//-/' | sed 's/amd/x/') && \
    curl -s "https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_SDK_VERSION}/sdk/dartsdk-${DART_ARCH}-release.zip" -o "dartsdk-${DART_ARCH}-release.zip" && \
    unzip "dartsdk-${DART_ARCH}-release.zip" && \
    rm "dartsdk-${DART_ARCH}-release.zip"

ENV DART_SASS_VERSION="1.79.4"
RUN DART_ARCH=$(echo $TARGETPLATFORM | sed 's/\//-/' | sed 's/amd/x/') && \
    curl -sL "https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/dart-sass-${DART_SASS_VERSION}-${DART_ARCH}.tar.gz" -o "${DART_SASS_VERSION}.tar.gz" && \
    tar -xvf "${DART_SASS_VERSION}.tar.gz" && \
    rm "${DART_SASS_VERSION}.tar.gz" && \
    mv dart-sass/* dart-sdk/bin/ && \
    rmdir dart-sass

# Setup cargo binstall
RUN curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

# We only pay the installation cost once, 
# it will be cached from the second build onwards
RUN cargo binstall cargo-chef@0.1 --no-confirm --locked
RUN cargo binstall trunk@0.16 --no-confirm --locked
RUN cargo binstall wasm-bindgen-cli@0.2.94 --no-confirm --locked
RUN cargo binstall tauri-cli@2.0 --no-confirm --locked

WORKDIR /app
