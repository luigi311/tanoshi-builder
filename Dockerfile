FROM rust:1.58.0 AS chef 
ARG TARGETPLATFORM
ARG BUILDPLATFORM
# We only pay the installation cost once, 
# it will be cached from the second build onwards
RUN cargo install cargo-chef trunk
RUN rustup target add wasm32-unknown-unknown

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
    unzip

RUN wget https://apt.llvm.org/llvm.sh && \ 
    chmod +x llvm.sh &&\ 
    ./llvm.sh 11

RUN wget "https://storage.googleapis.com/dart-archive/channels/stable/release/2.16.1/sdk/dartsdk-$(echo $TARGETPLATFORM | sed 's/\//-/')-release.zip" && \
    unzip "dartsdk-$(echo $TARGETPLATFORM | sed 's/\//-/')-release.zip"
RUN export PATH="$PATH:$HOME/dart-sdk/bin"

RUN wget https://github.com/sass/dart-sass/archive/refs/tags/1.49.9.zip && \
    unzip 1.49.9.zip && \
    cd dart-sass-1.49.9 && \
    dart pub get && \
    dart compile exe bin/sass.dart -o $HOME/dart-sdk/bin/sass -Dversion=1.49.9 && \
    
WORKDIR /app