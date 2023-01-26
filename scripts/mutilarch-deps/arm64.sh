#!/usr/bin/env bash

# --- arm64 ---
sudo apt install -y \
    linux-libc-dev-arm64-cross \
    libc6-arm64-cross libc6-dev-arm64-cross \
    binutils-aarch64-linux-gnu \
    gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
