#!/bin/bash
cd
echo "******************************************"
echo "---------- UPDATING GPCORE REPO ----------"
echo "******************************************"
cd riscv-piton/openpiton/piton/design/chip/tile/gpcore
git checkout OpenPiton
git pull
echo "Repo update Complete......"
cd
echo "******************************************"
echo "-------------- Building SOC --------------"
echo "******************************************"
cd riscv-piton/openpiton
export PATH="$HOME/riscv-piton/riscv/bin:$PATH"
export PATH=$PWD
source piton/piton_settings.bash
cd build
sims -sys=manycore -vlt_build -vlt_build_args=--trace -vlt_build_args=-CFLAGS -vlt_build_args=-DVERILATOR_VCD -gpcore
echo "SOC build complete......"
echo "******************************************"
echo "------------- Simulating SOC -------------"
echo "******************************************"
sims -sys=manycore -gpcore -vlt_run add.S
echo "******************************************"
echo "---------- Generating Dump File ----------"
echo "******************************************"
riscv64-unknown-elf-objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data diag.exe > diag.dump