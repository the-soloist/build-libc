#!/usr/bin/env bash

# --- riscv64 ---
sudo apt install -y \
    linux-libc-dev-riscv64-cross \
    libc6-riscv64-cross libc6-dev-riscv64-cross \
    binutils-riscv64-linux-gnu \
    gcc-riscv64-linux-gnu g++-riscv64-linux-gnu
