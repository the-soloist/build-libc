# --- mips 大端 ---
sudo apt install -y linux-libc-dev-mips-cross libc6-mips-cross libc6-dev-mips-cross binutils-mips-linux-gnu gcc-mips-linux-gnu g++-mips-linux-gnu

# --- mipsel 小端 ---
sudo apt install -y linux-libc-dev-mipsel-cross libc6-mipsel-cross libc6-dev-mipsel-cross binutils-mipsel-linux-gnu gcc-mipsel-linux-gnu g++-mipsel-linux-gnu

# --- mips64 大端 ---
sudo apt install -y linux-libc-dev-mips64-cross libc6-mips64-cross libc6-dev-mips64-cross binutils-mips64-linux-gnuabi64 gcc-mips64-linux-gnuabi64 g++-mips64-linux-gnuabi64

# --- mips64el 小端 ---
sudo apt install -y linux-libc-dev-mips64el-cross libc6-mips64el-cross libc6-dev-mips64el-cross binutils-mips64el-linux-gnuabi64 gcc-mips64el-linux-gnuabi64 g++-mips64el-linux-gnuabi64

# --- arm64/aarch64 ---
sudo apt install -y linux-libc-dev-arm64-cross libc6-arm64-cross libc6-dev-arm64-cross binutils-aarch64-linux-gnu gcc-aarch64-linux-gnu g++-aarch64-linux-gnu

# --- arm ---
sudo apt install -y linux-libc-dev-armhf-cross libc6-armhf-cross libc6-dev-armhf-cross libc6-armhf-armel-cross libc6-dev-armhf-armel-cross binutils-arm-linux-gnueabihf gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf
sudo apt install -y linux-libc-dev-armel-cross libc6-armel-cross libc6-dev-armel-cross libc6-armel-armhf-cross libc6-dev-armel-armhf-cross binutils-arm-linux-gnueabi gcc-arm-linux-gnueabi g++-arm-linux-gnueabi

# --- riscv64 ---
sudo apt install -y linux-libc-dev-riscv64-cross libc6-riscv64-cross libc6-dev-riscv64-cross binutils-riscv64-linux-gnu gcc-riscv64-linux-gnu g++-riscv64-linux-gnu
