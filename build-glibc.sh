#!/usr/bin/env bash
# set -x

LIBC_VERSION_ARRAY=(
    "2.19" "2.23" "2.24" "2.25" "2.26" "2.27" "2.28" "2.29" "2.30" "2.31" "2.32" "2.33" "2.34" "2.35" "2.36"
)
LIBC_ARCH_ARRAY=(
    "x64" "x64"
    "arm-linux-gnueabi" "arm-linux-gnueabihf" "aarch64-linux-gnu"
    "mips-linux-gnu" "mips64-linux-gnuabi64" "mipsel-linux-gnu" "mips64el-linux-gnuabi64"
)

LIBC_HOME="/opt/glibc"

NOW_TIME=$(date "+%Y-%m-%d_%H:%M:%S")
CUSTOM_NAME="\"ignore this unless you set custom config (-c)\""

BUILD_LOG="/tmp/log/build-glibc"
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
    echo "==> compress glibc:"
    echo "cd $LIBC_HOME/$LIBC_ARCH"
    if [ -z "$CUSTOM_CONFIG" ]; then
        echo "tar -Jcvf ../glibc-$LIBC_ARCH-$LIBC_VERSION.tar.xz $LIBC_VERSION"
    else
        echo "tar -Jcvf ../glibc-$LIBC_ARCH-$LIBC_VERSION-$CUSTOM_NAME.tar.xz $LIBC_VERSION-$CUSTOM_NAME"
    fi

}

function pause() {
    read -n 1 -p "Press any key to continue..." INP
}

function init_libc_home() {
    echo ">>> init glibc home"

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
    echo ">>> download glibc source"

    cd $LIBC_HOME/source
    if [ ! -d "$LIBC_HOME/source/glibc-$Version" ]; then
        wget "http://mirrors.ustc.edu.cn/gnu/libc/glibc-$Version.tar.gz"
        tar -xf glibc-$Version.tar.gz
    else
        echo "[*] $LIBC_HOME/source/glibc-$Version already exists"
    fi

    echo -e ">>> done\n"
}

function clean_libc_trash() {
    # $1: version
    Version=$1
    echo ">>> clean glibc trash"

    cd $LIBC_HOME/source
    rm "glibc-$Version.tar.gz"
    rm -rf "glibc-$Version/build"

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
    echo ">>> install glibc"

    if [ -f "$Prefix/lib/libc.so.6" ]; then
        echo "$Arch glibc $Version already installed!"
        exit -1
    fi

    echo -e "[init] build dir"
    mkdir -p "$Prefix"
    mkdir -p "$LIBC_HOME/source/glibc-$Version/build"
    cd "$LIBC_HOME/source/glibc-$Version/build"

    echo -e "[run] configure"
    if [ $Arch == "x64" ]; then
        ../configure \
            --prefix="$Prefix" \
            --disable-werror --enable-debug=yes \
            "$CUSTOM_CONFIG" >"$LOG_CONFIGURE" 2>&1
    elif [ $Arch == "x86" ]; then
        ../configure \
            CC="$CC" CXX="$CXX" \
            --prefix="$Prefix" \
            --disable-werror --enable-debug=yes \
            --host=i686-linux-gnu --build=i686-linux-gnu \
            "$CUSTOM_CONFIG" >"$LOG_CONFIGURE" 2>&1
    else # mutilarch
        ../configure \
            CC="$CC" CXX="$CXX" \
            --prefix="$Prefix" \
            --disable-werror --enable-debug=yes \
            --host=$HOST --target=$TARGET \
            "$CUSTOM_CONFIG" >"$LOG_CONFIGURE" 2>&1
    fi

    echo -e "[run] make -j8"
    make -j8 >"$LOG_MAKE" 2>&1
    echo -e "[run] make install"
    make install >"$LOG_MAKE_INSTALL" 2>&1

    if [ -f "$Prefix/lib/libc.so.6" ]; then
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
    d) # just download glibc source code
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
