#!/usr/bin/env bash
# set -x

LIBC_VERSION_ARRAY=(
    "0.5.0" "0.5.9" "0.6.0" "0.7.0" "0.7.1" "0.7.10" "0.7.11" "0.7.12" "0.7.5" "0.7.6" "0.7.7" "0.7.8" "0.7.9" "0.8.0" "0.8.1" "0.8.10" "0.8.2" "0.8.3" "0.8.4" "0.8.5" "0.8.6" "0.8.7" "0.8.8" "0.8.9" "0.9.0" "0.9.1" "0.9.10" "0.9.11" "0.9.12" "0.9.13" "0.9.14" "0.9.15" "0.9.2" "0.9.3" "0.9.4" "0.9.5" "0.9.6" "0.9.7" "0.9.8" "0.9.9" "1.0.0" "1.0.1" "1.0.2" "1.0.3" "1.0.4" "1.0.5" "1.1.0" "1.1.1" "1.1.10" "1.1.11" "1.1.12" "1.1.13" "1.1.14" "1.1.15" "1.1.16" "1.1.17" "1.1.18" "1.1.19" "1.1.2" "1.1.20" "1.1.21" "1.1.22" "1.1.23" "1.1.24" "1.1.3" "1.1.4" "1.1.5" "1.1.6" "1.1.7" "1.1.8" "1.1.9" "1.2.0" "1.2.1" "1.2.2" "1.2.3"
)
LIBC_ARCH_ARRAY=(
    "x64" "x64"
    "arm-linux-gnueabi" "arm-linux-gnueabihf" "aarch64-linux-gnu"
    "mips-linux-gnu" "mips64-linux-gnuabi64" "mipsel-linux-gnu" "mips64el-linux-gnuabi64"
)

LIBC_HOME="/opt/musl-libc"

NOW_TIME=$(date "+%Y-%m-%d_%H:%M:%S")
CUSTOM_NAME="\"ignore this unless you set custom config (-c)\""

BUILD_LOG="/tmp/log/build-musl-libc"
LOG_CONFIGURE="$BUILD_LOG/configure_$NOW_TIME.log"
LOG_MAKE="$BUILD_LOG/make_$NOW_TIME.log"
LOG_MAKE_INSTALL="$BUILD_LOG/make-install_$NOW_TIME.log"

function print_help() {
    cat <<EOF
Usage:
    bash $0 [-a arch] [-v libc_version] [-m more_debug_info] [-d download_libc] [-c set_custom_config] [-n set_custom_name]

    option -a: 
        x64 x86
        arm-linux-gnueabi   arm-linux-gnueabihf     aarch64-linux-gnu
        mips-linux-gnu      mips64-linux-gnuabi64   mipsel-linux-gnu    mips64el-linux-gnuabi64

    option -v: 
        all ${LIBC_VERSION_ARRAY[*]}

    option -c:
        --disable-experimental-malloc: disable tcache

    examples:
        bash $0 -a x64 -v all
        bash $0 -a x64 -v 2.3x
        bash $0 -a x64 -v 2.3x -c "--disable-experimental-malloc" -n "no_tcache"
        bash $0 -d 2.3x
EOF
    exit -1
}

function print_end_info() {
    # $1 version
    echo "==> compress musl-libc:"
    echo "cd $LIBC_HOME/$LIBC_ARCH"
    if [ -z "$CUSTOM_CONFIG" ]; then
        echo "tar -Jcvf ../musl-$LIBC_ARCH-$LIBC_VERSION.tar.xz $LIBC_VERSION"
    else
        echo "tar -Jcvf ../musl-$LIBC_ARCH-$LIBC_VERSION-$CUSTOM_NAME.tar.xz $LIBC_VERSION-$CUSTOM_NAME"
    fi

}

function pause() {
    read -n 1 -p "Press any key to continue..." INP
}

function init_libc_home() {
    echo ">>> init musl-libc home"

    mkdir -p $BUILD_LOG

    echo >"$LOG_CONFIGURE"
    echo >"$LOG_MAKE"
    echo >"$LOG_MAKE_INSTALL"

    mkdir -p $LIBC_HOME
    mkdir -p $LIBC_HOME/source

    echo -e ">>> done\n"
}

function init_complie_args() {
    # $1: arch
    Arch=$1
    echo ">>> init complie args"

    if [ $Arch == "x64" ]; then
        echo "compile x64"
    elif [ $Arch == "x86" ]; then
        echo "compile x86"
        CC="gcc -m32"
        CXX="g++ -m32"
    else
        echo "compile cross arch"
        CC=$Arch-gcc
        CXX=$Arch-g++
        HOST=$Arch
        TARGET=$Arch
    fi

    echo -e ">>> done\n"
}

function install_complie_dependence() {
    # $1: arch
    Arch=$1
    echo ">>> install complie dependence"

    sudo apt install -y gawk bison
    if [ $Arch == "x64" ] || [ $Arch == "x86" ]; then
        sudo apt install -y gcc-multilib g++-multilib
    else
        # while read line; do
        #     $line
        # done <"scripts/mutilarch-dependencies.txt"
        bash ./scripts/install_mutilarch_dependencies.sh
    fi

    echo -e ">>> done\n"
}

function download_libc_source() {
    # $1: version
    Version=$1
    echo ">>> download musl-libc source"

    cd $LIBC_HOME/source
    if [ ! -d "$LIBC_HOME/source/musl-$Version" ]; then
        wget "https://musl.libc.org/releases/musl-$Version.tar.gz"
        tar -xf musl-$Version.tar.gz
    else
        echo "[*] $LIBC_HOME/source/musl-$Version already exists"
    fi

    echo -e ">>> done\n"
}

function clean_libc_trash() {
    # $1: version
    Version=$1
    echo ">>> clean musl-libc trash"

    cd $LIBC_HOME/source
    rm "musl-$Version.tar.gz"
    rm -rf "musl-$Version/build"

    echo -e ">>> done\n"
}

function install_libc() {
    # $1: arch
    # $2: version
    Arch=$1
    Version=$2
    if [ -z "$CUSTOM_CONFIG" ]; then
        Prefix="$LIBC_HOME/$Arch/$Version"
    else
        Prefix="$LIBC_HOME/$Arch/$Version-$CUSTOM_NAME"
    fi
    echo ">>> install musl-libc"

    if [ -f "$Prefix/lib/libc.so" ]; then
        echo "$Arch musl-libc $Version already installed!"
        exit -1
    fi

    echo -e "[init] build dir"
    mkdir -p "$Prefix"
    mkdir -p "$LIBC_HOME/source/musl-$Version/build"
    cd "$LIBC_HOME/source/musl-$Version/build"

    echo -e "[run] configure"
    if [ $Arch == "x64" ]; then
        ../configure \
            --prefix="$Prefix" \
            --disable-werror \
            "$CUSTOM_CONFIG" >"$LOG_CONFIGURE" 2>&1
    elif [ $Arch == "x86" ]; then
        ../configure \
            CC="$CC" CXX="$CXX" \
            --prefix="$Prefix" \
            --disable-werror \
            --host=i686-linux-gnu --build=i686-linux-gnu \
            "$CUSTOM_CONFIG" >"$LOG_CONFIGURE" 2>&1
    else # mutilarch
        ../configure \
            CC="$CC" CXX="$CXX" \
            --prefix="$Prefix" \
            --disable-werror \
            --host=$HOST --target=$TARGET \
            "$CUSTOM_CONFIG" >"$LOG_CONFIGURE" 2>&1
    fi

    echo -e "[run] make -j8"
    make -j8 >"$LOG_MAKE" 2>&1
    echo -e "[run] make install"
    make install >"$LOG_MAKE_INSTALL" 2>&1

    if [ -f "$Prefix/lib/libc.so" ]; then
        echo -e ">>> install $Prefix done\n"
    else
        echo -e ">>> install $Prefix failed!\n"

        echo -e "[log] make"
        tail -n 30 "$LOG_MAKE"
        echo -e "[log] make install"
        tail -n 30 "$LOG_MAKE_INSTALL"

        exit -1
    fi
}

while getopts "a:v:c:n:d:mh" OPT; do
    case $OPT in
    a) LIBC_ARCH="$OPTARG" ;;
    v) LIBC_VERSION="$OPTARG" ;;
    c) CUSTOM_CONFIG="$OPTARG" ;;
    n) CUSTOM_NAME="$OPTARG" ;;
    m) # compile with more debug info
        CFLAGS="-g -g3 -ggdb -gdwarf-4 -Og -w"
        CXXFLAGS="-g -g3 -ggdb -gdwarf-4 -Og -w"
        ;;
    d) # just download musl-libc source code
        init_libc_home
        download_libc_source "$OPTARG"
        clean_libc_trash "$OPTARG"
        exit 0
        ;;
    h) print_help ;;
    ?) print_help ;;
    esac
done

### check args
if [ -z "$LIBC_ARCH" ] && [[ "${LIBC_ARCH_ARRAY[@]}" =~ "$LIBC_ARCH" ]]; then
    echo -e "please set LIBC_ARCH\n"
    print_help
fi
if [ -z "$LIBC_VERSION" ] && [[ "${LIBC_VERSION_ARRAY[@]}" =~ "$LIBC_VERSION" ]]; then
    echo -e "please set LIBC_VERSION\n"
    print_help
fi

### init build env
init_libc_home
init_complie_args $LIBC_ARCH
install_complie_dependence $LIBC_ARCH

echo "================================ info ================================"
echo "NOW_TIME:      $NOW_TIME"
echo "LIBC_ARCH:     $LIBC_ARCH"
echo "LIBC_VERSION:  $LIBC_VERSION"
echo "CUSTOM_CONFIG: $CUSTOM_CONFIG"
echo "CUSTOM_NAME:   $CUSTOM_NAME"
echo "CC:            $CC"
echo "CXX:           $CXX"
echo "HOST:          $HOST"
echo "TARGET:        $TARGET"
echo "======================================================================"

pause

if [ -n "$LIBC_VERSION" ] && [ "$LIBC_VERSION" != "all" ]; then
    echo -e "\n### compile $LIBC_VERSION ###\n"
    download_libc_source $LIBC_VERSION
    clean_libc_trash $LIBC_VERSION
    install_libc $LIBC_ARCH $LIBC_VERSION
    print_end_info $LIBC_VERSION
else
    for LIBC_VERSION in ${LIBC_VERSION_ARRAY[@]}; do
        echo -e "\n### compile $LIBC_VERSION ###\n"
        download_libc_source $LIBC_VERSION
        clean_libc_trash $LIBC_VERSION
        install_libc $LIBC_ARCH $LIBC_VERSION
        print_end_info $LIBC_VERSION
    done
fi
