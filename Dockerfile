FROM rust:1.58.0 AS chef 
ARG TARGETPLATFORM
ARG BUILDPLATFORM

RUN apt update && \
    apt upgrade -y && \
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
    binaryen

WORKDIR /root

RUN DART_ARCH=$(echo $TARGETPLATFORM | sed 's/\//-/' | sed 's/amd/x/') && \
    wget "https://storage.googleapis.com/dart-archive/channels/stable/release/2.16.1/sdk/dartsdk-$DART_ARCH-release.zip" && \
    unzip "dartsdk-$DART_ARCH-release.zip"
ENV PATH="$PATH:/root/dart-sdk/bin"

RUN DART_VERSION="1.49.9" && \
    wget "https://github.com/sass/dart-sass/archive/refs/tags/$DART_VERSION.zip" && \
    unzip "$DART_VERSION.zip" && \
    cd "dart-sass-$DART_VERSION" && \
    dart pub get && \
    dart compile exe bin/sass.dart -o /root/dart-sdk/bin/sass -Dversion="$DART_VERSION"

# We only pay the installation cost once, 
# it will be cached from the second build onwards
RUN cargo install cargo-chef 
RUN cargo install trunk 
RUN cargo install wasm-bindgen-cli
RUN rustup target add wasm32-unknown-unknown

WORKDIR /app