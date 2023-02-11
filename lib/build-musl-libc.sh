#!/usr/bin/env bash
# set -x

LIBC_FULL_NAME="musl-libc"
LIBC_SHORT_NAME="musl"

LIBC_VERSION_ARRAY=(
    "0.5.0" "0.5.9"
    "0.6.0"
    "0.7.0" "0.7.1" "0.7.5" "0.7.6" "0.7.7" "0.7.8" "0.7.9" "0.7.10" "0.7.11" "0.7.12"
    "0.8.0" "0.8.1" "0.8.2" "0.8.3" "0.8.4" "0.8.5" "0.8.6" "0.8.7" "0.8.8" "0.8.9" "0.8.10"
    "0.9.0" "0.9.1" "0.9.2" "0.9.3" "0.9.4" "0.9.5" "0.9.6" "0.9.7" "0.9.8" "0.9.9" "0.9.10" "0.9.11" "0.9.12" "0.9.13" "0.9.14" "0.9.15"
    "1.0.0" "1.0.1" "1.0.2" "1.0.3" "1.0.4" "1.0.5"
    "1.1.0" "1.1.1" "1.1.2" "1.1.3" "1.1.4" "1.1.5" "1.1.6" "1.1.7" "1.1.8" "1.1.9" "1.1.10" "1.1.11" "1.1.12" "1.1.13" "1.1.14" "1.1.15" "1.1.16" "1.1.17" "1.1.18" "1.1.19" "1.1.20" "1.1.21" "1.1.22" "1.1.23" "1.1.24"
    "1.2.0" "1.2.1" "1.2.2" "1.2.3"
)

LIBC_ARCH_ARRAY=(
    "x86" "x86_64"
    "arm-linux-gnueabi" "arm-linux-gnueabihf" "arm-none-eabi" "aarch64-linux-gnu"
    "mips-linux-gnu" "mipsel-linux-gnu" "mips64-linux-gnuabi64" "mips64el-linux-gnuabi64"
    "riscv64-linux-gnu"
)

function download_libc_source() {
    # $1: libc version
    _version=$1

    echo ">>> download $LIBC_FULL_NAME source"

    cd $LIBC_HOME/source
    if [ ! -d "$LIBC_HOME/source/musl-$_version" ]; then
        wget "https://musl.libc.org/releases/musl-$_version.tar.gz"
        tar -xf musl-$_version.tar.gz
    else
        echo "[*] $LIBC_HOME/source/musl-$_version already exists"
    fi

    echo -e ">>> done\n"
}

function install_libc() {
    # $1: host arch
    # $2: libc version
    _arch=$1
    _version=$2

    if [ -z "$CUSTOM_CONFIG" ]; then
        _prefix="$LIBC_HOME/$_arch/$_version"
    else
        _prefix="$LIBC_HOME/$_arch/$_version-$CUSTOM_NAME"
    fi

    echo ">>> install $LIBC_FULL_NAME"

    if [ -f "$_prefix/lib/libc.so" ]; then
        echo "musl-libc $_version ($_arch) already installed!"
        exit 1
    fi

    echo -e "[init] build dir"
    mkdir -p "$_prefix"
    mkdir -p "$LIBC_HOME/source/musl-$_version/build"
    cd "$LIBC_HOME/source/musl-$_version/build"

    echo -e "[run] configure"
    if [ $_arch == "x86_64" ]; then
        ../configure \
            --prefix="$_prefix" \
            --disable-werror \
            "$CUSTOM_CONFIG" >"$LOG_CONFIGURE" 2>&1
    elif [ $_arch == "x86" ]; then
        ../configure \
            CC="$CC" CXX="$CXX" \
            --prefix="$_prefix" \
            --disable-werror \
            --host=i686-linux-gnu --build=i686-linux-gnu \
            "$CUSTOM_CONFIG" >"$LOG_CONFIGURE" 2>&1
    else # mutilarch
        ../configure \
            CC="$CC" CXX="$CXX" \
            --prefix="$_prefix" \
            --disable-werror \
            --host=$HOST --target=$TARGET \
            "$CUSTOM_CONFIG" >"$LOG_CONFIGURE" 2>&1
    fi

    echo -e "[run] make (thread: $COMPILE_THREAD)"
    make -j$COMPILE_THREAD >"$LOG_MAKE" 2>&1
    echo -e "[run] make install"
    make install >"$LOG_MAKE_INSTALL" 2>&1

    if [ -f "$_prefix/lib/libc.so" ]; then
        echo -e ">>> install $_prefix done\n"
    else
        echo -e ">>> install $_prefix failed!\n"
        print_error_log 30
    fi
}
