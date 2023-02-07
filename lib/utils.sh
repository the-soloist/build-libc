#!/usr/bin/env bash

function print_help() {
    cat <<EOF
Usage:
    bash $0 [-l LIBC_FULL_NAME] [-a LIBC_ARCH] [-v LIBC_VERSION] [-t THREAD] [-c CUSTOM_CONFIG] [-n CUSTOM_NAME]
            [-d download_libc] [-m more_debug_info]

    option -l:
        glibc
        musl-libc

    option -a: 
        x86 x86_64
        arm-linux-gnueabi   arm-linux-gnueabihf   aarch64-linux-gnu
        mips-linux-gnu      mipsel-linux-gnu      mips64-linux-gnuabi64   mips64el-linux-gnuabi64
        riscv64-linux-gnu

    option -v: 
        all ${LIBC_VERSION_ARRAY[*]}

    option -c:
        --disable-experimental-malloc: disable tcache

    examples:
        bash $0 -l "glibc" -a x86_64 -v 2.3x -c "--disable-experimental-malloc" -n "no_tcache"
        bash $0 -l "glibc" -a x86_64 -v 2.3x -t 16
        bash $0 -l "glibc" -a x86_64 -v all
        bash $0 -l "glibc" -d 2.3x
        bash $0 -l "glibc" -h
        bash $0 -l "musl-libc" -a x86_64 -v 1.2.x
        bash $0 -l "musl-libc" -d 1.2.x
EOF
    exit 1
}

function init_complie_args() {
    # $1: host arch
    _arch="$1"

    echo ">>> init complie args"

    if [ $_arch == "x86_64" ]; then
        echo "compile x86_64"
    elif [ $_arch == "x86" ]; then
        echo "compile x86"
        CC="gcc -m32"
        CXX="g++ -m32"
    else
        echo "compile cross arch"
        CC="$_arch-gcc"
        CXX="$_arch-g++"
        HOST="$_arch"
        TARGET="$_arch"
    fi

    echo -e ">>> done\n"
}

function install_complie_dependence() {
    # $1: host arch
    _arch="$1"

    echo ">>> install complie dependence ($_arch)"

    sudo apt install -y gawk bison
    if [ $_arch == "x86_64" ] || [ $_arch == "x86" ]; then
        sudo apt install -y gcc-multilib g++-multilib
    elif [[ $_arch =~ ^"arm" ]]; then
        bash "./scripts/mutilarch-deps/arm.sh"
    elif [[ $_arch =~ ^"aarch64" ]]; then
        bash "./scripts/mutilarch-deps/arm64.sh"
    elif [[ $_arch =~ ^"mips-" ]] || [[ $_arch =~ ^"mipsel" ]]; then
        bash "./scripts/mutilarch-deps/mips.sh"
    elif [[ $_arch =~ ^"mips64" ]]; then
        bash "./scripts/mutilarch-deps/mips64.sh"
    elif [[ $_arch =~ ^"riscv64" ]]; then
        bash "./scripts/mutilarch-deps/riscv64.sh"
    fi

    echo -e ">>> done\n"
}

function init_libc_home() {
    echo ">>> init $LIBC_FULL_NAME home"

    mkdir -p "$BUILD_LOG"

    # echo >"$LOG_CONFIGURE"
    # echo >"$LOG_MAKE"
    # echo >"$LOG_MAKE_INSTALL"

    mkdir -p "$LIBC_HOME"
    mkdir -p "$LIBC_HOME/source"

    echo -e ">>> done\n"
}

function clean_libc_trash() {
    # $1: libc version
    _version="$1"

    echo ">>> clean $LIBC_SHORT_NAME trash"

    cd $LIBC_HOME/source
    rm "$LIBC_SHORT_NAME-$_version.tar.gz"
    rm -rf "$LIBC_SHORT_NAME-$_version/build"

    echo -e ">>> done\n"
}

function download_libc_source() {
    echo "nothing to do, please define 'download_libc_source'"
    exit 1
}

function install_libc() {
    echo "nothing to do, please define 'install_libc'"
    exit 1
}

function print_start_info() {
    echo "==================================== build info ===================================="
    echo "LIBC_FULL_NAME:   $LIBC_FULL_NAME"
    echo "LIBC_SHORT_NAME:  $LIBC_SHORT_NAME"
    echo "LIBC_HOME:        $LIBC_HOME"
    echo "NOW_TIME:         $NOW_TIME"
    echo "BUILD_LOG:        $BUILD_LOG"
    echo "LOG_CONFIGURE:    $LOG_CONFIGURE"
    echo "LOG_MAKE:         $LOG_MAKE"
    echo "LOG_MAKE_INSTALL: $LOG_MAKE_INSTALL"
    echo "=================================== compile info ==================================="
    echo "LIBC_ARCH:      $LIBC_ARCH"
    echo "LIBC_VERSION:   $LIBC_VERSION"
    echo "CUSTOM_CONFIG:  $CUSTOM_CONFIG"
    echo "CUSTOM_NAME:    $CUSTOM_NAME"
    echo "COMPILE_THREAD: $COMPILE_THREAD"
    echo "CC:             $CC"
    echo "CXX:            $CXX"
    echo "HOST:           $HOST"
    echo "TARGET:         $TARGET"
    echo "===================================================================================="
}

function print_end_info() {
    echo "==> compress $LIBC_FULL_NAME:"
    echo "cd $LIBC_HOME/$LIBC_ARCH"

    if [ -z "$CUSTOM_CONFIG" ]; then
        echo "tar -Jcvf ../$LIBC_SHORT_NAME-$LIBC_ARCH-$LIBC_VERSION.tar.xz $LIBC_VERSION"
    else
        echo "tar -Jcvf ../$LIBC_SHORT_NAME-$LIBC_ARCH-$LIBC_VERSION-$CUSTOM_NAME.tar.xz $LIBC_VERSION-$CUSTOM_NAME"
    fi
}

function pause() {
    read -n 1 -p "Press any key to continue..." INP
}
