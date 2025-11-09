# --- ppc64 ---
sudo apt install -y \
    linux-libc-dev-ppc64-cross \
    libc6-ppc64-cross libc6-dev-ppc64-cross \
    binutils-powerpc64-linux-gnu \
    gcc-powerpc64-linux-gnu g++-powerpc64-linux-gnu

# --- ppc64el ---
sudo apt install -y \
    linux-libc-dev-ppc64el-cross \
    libc6-ppc64el-cross libc6-dev-ppc64el-cross \
    binutils-powerpc64le-linux-gnu \
    gcc-powerpc64le-linux-gnu g++-powerpc64le-linux-gnu