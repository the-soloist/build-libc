#!/usr/bin/env bash
# set -x

LIBC_FULL_NAME="glibc"
LIBC_SHORT_NAME="glibc"

LIBC_VERSION_ARRAY=(
    "2.10.1" "2.11" "2.11.1" "2.11.2" "2.11.3" "2.12.1" "2.12.2" "2.13" "2.14" "2.14.1" "2.15" "2.16.0" "2.17" "2.18" "2.19"
    "2.23" "2.24" "2.25" "2.26" "2.27" "2.28" "2.29"
    "2.30" "2.31" "2.32" "2.33" "2.34" "2.35" "2.36" "2.37"
)

LIBC_ARCH_ARRAY=(
    "x86" "x86_64"
    "arm-linux-gnueabi" "arm-linux-gnueabihf" "aarch64-linux-gnu"
    "mips-linux-gnu" "mipsel-linux-gnu" "mips64-linux-gnuabi64" "mips64el-linux-gnuabi64"
    "riscv64-linux-gnu"
)

NOW_TIME=$(date "+%Y-%m-%d_%H:%M:%S")

LIBC_HOME="/opt/$LIBC_FULL_NAME"
BUILD_LOG="/tmp/log/build-$LIBC_FULL_NAME"
LOG_CONFIGURE="$BUILD_LOG/configure_$NOW_TIME.log"
LOG_MAKE="$BUILD_LOG/make_$NOW_TIME.log"
LOG_MAKE_INSTALL="$BUILD_LOG/make-install_$NOW_TIME.log"

COMPILE_THREAD="8"
CUSTOM_NAME="\"ignore this unless you set custom config (-c)\""

function download_libc_source() {
    # $1: libc version
    _version=$1

    echo ">>> download $LIBC_FULL_NAME source"

    cd $LIBC_HOME/source
    if [ ! -d "$LIBC_HOME/source/glibc-$_version" ]; then
        wget "http://mirrors.ustc.edu.cn/gnu/libc/glibc-$_version.tar.gz"
        tar -xf glibc-$_version.tar.gz
    else
        echo "[*] $LIBC_HOME/source/glibc-$_version already exists"
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

    if [ -f "$_prefix/lib/libc.so.6" ]; then
        echo "glibc $_version ($_arch) already installed!"
        exit 1
    fi

    echo -e "[init] build dir"
    mkdir -p "$_prefix"
    mkdir -p "$LIBC_HOME/source/glibc-$_version/build"
    cd "$LIBC_HOME/source/glibc-$_version/build"

    echo -e "[run] configure"
    if [ $_arch == "x86_64" ]; then
        ../configure \
            --prefix="$_prefix" \
            --disable-werror --enable-debug=yes \
            "$CUSTOM_CONFIG" >"$LOG_CONFIGURE" 2>&1
    elif [ $_arch == "x86" ]; then
        ../configure \
            CC="$CC" CXX="$CXX" \
            --prefix="$_prefix" \
            --disable-werror --enable-debug=yes \
            --host=i686-linux-gnu --build=i686-linux-gnu \
            "$CUSTOM_CONFIG" >"$LOG_CONFIGURE" 2>&1
    else # mutilarch
        ../configure \
            CC="$CC" CXX="$CXX" \
            --prefix="$_prefix" \
            --disable-werror --enable-debug=yes \
            --host=$HOST --target=$TARGET \
            "$CUSTOM_CONFIG" >"$LOG_CONFIGURE" 2>&1
    fi

    echo -e "[run] make (thread: $COMPILE_THREAD)"
    make -j$COMPILE_THREAD >"$LOG_MAKE" 2>&1
    echo -e "[run] make install"
    make install >"$LOG_MAKE_INSTALL" 2>&1

    if [ -f "$_prefix/lib/libc.so.6" ]; then
        echo -e ">>> install $_prefix done\n"
    else
        echo -e ">>> install $_prefix failed!\n"

        echo -e "[log] make"
        tail -n 30 "$LOG_MAKE"
        echo -e "[log] make install"
        tail -n 30 "$LOG_MAKE_INSTALL"

        exit 1
    fi
}
