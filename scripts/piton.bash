#!/bin/bash
echo "PITON & RISCV ENVIRONMENT SETUP"
echo "A directory called riscv-piton will be created"
echo "BY: Omar Younis"
echo "******************************"
echo "--- UPDATING PACKAGE LISTS ---"
echo "******************************"
sudo apt update 
echo "**************************"
echo "--- UPGRADING PACKAGES ---"
echo "**************************"
sudo apt upgrade 
echo "**************************************"
echo "--- INSTALLING ADDITIONAL PACKAGES ---"
echo "**************************************" 
sudo apt install -y build-essential git subversion
sudo apt install -y python2 python2-dev libpython2-dev
sudo apt install -y python3 python3-dev libpython3-dev
sudo apt install -y perl python
sudo apt install -y apache2 apache2-dev pkg-config perl
sudo apt install -y libapr1 libapr1-dev libreadline5 libreadline-dev bison flex
sudo apt install -y libncurses5 libncurses5-dev gperf 
sudo apt install -y autoconf automake autotools-dev curl
sudo apt install -y libmpc-dev libmpfr-dev libgmp-dev gawk texinfo libtool patchutils bc zlib1g-dev libexpat-dev
echo "********************************"
echo "--- INSTALLING CORE PACKAGES ---"
echo "********************************"
echo "Installing verilator......"
sudo apt install -y verilator
echo "Installing gtkwave......"
sudo apt install -y gtkwave
echo "Installing PyHP...... THIS WILL TAKE SOME TIME"
cd 
echo "Grapping the repositroy......"
svn checkout svn://svn.code.sf.net/p/pyhp/code/ pyhp-code
echo "Installing PyHP......"
cd pyhp-code
autoreconf -i
./configure
make
sudo make install
echo "PyHP INSTALLATION COMPLETE"
cd
echo "--- MAKING DIRECTORY riscv-piton"
mkdir riscv-piton
cd riscv-piton
echo "*******************************"
echo "--- Grapping OpenPiton Repo ---"
echo "*******************************"
git clone https://github.com/alaasal/openpiton.git
cd openpiton
git checkout gpcore
git submodule update --init --recursive piton/design/chip/tile/gpcore
cd piton/design/chip/tile/gpcore
git checkout OpenPiton
cd 
cd riscv-piton/openpiton
mkdir -p build/manycore/rel-0.1
cd
echo "******************************************"
echo "--- Grapping Riscv Gnu Toolchain Repo. ---"
echo "******************************************"
echo "WARNING: THIS IS A 4GB DOWNLOAD:"
echo "1- Make sure you have sufficeint internet capacity and sufficient space."
echo "2- Make sure you are ready to wait for it to finish"
echo "If YES enter a capital y, MUST BE Y"
read -p "Are You Ready? [Y/N]: " READY && [[ $READY == [yY] || $READY == [yY][eE][sS] ]] || exit 1
cd riscv-piton
git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
git submodule update --init --recursive
echo "******************************"
echo "--- RISCV elf make process ---"
echo "******************************"
echo "WARNING: THE FOLLOWING IS A LONG MAKE PROCESS "
read -p "ARE YOU READ?!! [Y/N]: " READY1 && [[ $READY1 == [yY] || $READY1 == [yY][eE][sS] ]] || exit 1
./configure --prefix=$HOME/riscv-piton/riscv
make
echo "Hooray! The make process is complete"
export PATH="$HOME/riscv-piton/riscv/bin:$PATH"
cd 
cd riscv-piton/openpiton
export PITON_ROOT=$PWD
source piton/piton_settings.bash
cd build
echo "Final touches..............."
sims -sys=manycore -vlt_build -gpcore
echo "Hooraaaaaaaaay we have done it....... I GUESS  ¯\_(ツ)_/¯"
echo "Byyeeeee!"