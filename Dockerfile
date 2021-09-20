FROM rust:latest AS chef 
# We only pay the installation cost once, 
# it will be cached from the second build onwards
RUN cargo install cargo-chef 
WORKDIR /app

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
    software-properties-common

RUN wget https://apt.llvm.org/llvm.sh && \ 
    chmod +x llvm.sh &&\ 
    ./llvm.sh 11