FROM debian:bookworm AS chef 
ARG TARGETPLATFORM
ARG BUILDPLATFORM

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        libssl-dev \
        libarchive-dev \
        build-essential \
        cmake \
        llvm \
        clang \
        libicu-dev \
        nettle-dev \
        libacl1-dev \
        liblzma-dev \
        libzstd-dev \
        liblz4-dev \
        libbz2-dev \
        zlib1g-dev \
        libxml2-dev \
        lsb-release \
        wget \
        software-properties-common \
        libwebkit2gtk-4.0-dev \
        curl \
        libgtk-3-dev \
        patchelf \
        librsvg2-dev\
        libpango1.0-dev \
        unzip \
        binaryen && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain 1.71.1
ENV PATH="$PATH:/root/.cargo/bin"

RUN rustup target add wasm32-unknown-unknown

WORKDIR /root

ENV DART_SDK_VERSION="3.0.7"
RUN DART_ARCH=$(echo $TARGETPLATFORM | sed 's/\//-/' | sed 's/amd/x/') && \
    curl -s "https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_SDK_VERSION}/sdk/dartsdk-${DART_ARCH}-release.zip" -o "dartsdk-${DART_ARCH}-release.zip" && \
    unzip "dartsdk-${DART_ARCH}-release.zip"

ENV PATH="$PATH:/root/dart-sdk/bin:/root/.cargo/bin"

ENV DART_SASS_VERSION="1.58.0"
RUN curl -sL "https://github.com/sass/dart-sass/archive/refs/tags/${DART_SASS_VERSION}.zip" -o "${DART_SASS_VERSION}.zip" && \
    unzip "${DART_SASS_VERSION}.zip" && \
    cd "dart-sass-${DART_SASS_VERSION}" && \
    dart pub get && \
    dart compile exe bin/sass.dart -o /root/dart-sdk/bin/sass -Dversion="${DART_SASS_VERSION}"

# We only pay the installation cost once, 
# it will be cached from the second build onwards
RUN cargo install cargo-chef --locked --version 0.1.62
# Lock trunk at 0.16.0 to avoid https://github.com/thedodd/trunk/issues/575
RUN cargo install trunk --locked --version 0.16.0
RUN cargo install wasm-bindgen-cli --locked --version 0.2.87

WORKDIR /app