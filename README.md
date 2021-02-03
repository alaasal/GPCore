# AlexCore
## This is the base repo for our graduation project in AlexU 21 building Linux-capable RISCV SoC
![alt text](https://github.com/alaasal/GPCore/blob/master/AlexSoC.PNG?raw=true)

#### uProcessor Design
This is a 6 stage riscv 32 IM built originally to form a SoC with OpenPiton and to be optimized for cryptography by connecting a specific IP.
- In-order RV32IM.
- Use scoreboard to stall on every hazard (most simple fix).
- OpenPiton Integration (to leverage Caches and Atomic Operations). 
- Privileged ISA.
- Crypto IP.

### Install OpenPiton+AlexCore

A step by step how to get a development env running

Install RISCV Toolchain
```
//Install Prerequisites
$ sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

//Cloning the toolchain repo
$ git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
$ cd riscv-gnu-toolchain

//Making sure everything is correct
$ git submodule update --init --recursive

//configuring installation path to a folder "riscv" in your home
$ ./configure --prefix=/${HOME}/riscv

//making riscv elf compilers to target baremetal binaries
//its name is riscv64 but it can target both 32 and 64
//you can specify your specific isa using -march
$ make
$ export PATH="$(HOME)/riscv/bin:$PATH" 
```

Install Verilator and GTKWave for Simulation
```
$ sudo apt-get update -y
$ sudo apt-get install verilator
$ sudo apt-get install -y gtkwave
```

Get OpenPiton+AlexCore
```
#First Download this file and copy it to OpenPiton: https://drive.google.com/file/d/15AjxohHkvQj7cLpKxNZY0_YukZogc9RK/view?usp=sharing
$ git clone https://github.com/alaasal/openpiton.git
$ cd openpiton
$ git checkout gpcore
$ git submodule update --init --recursive piton/design/chip/tile/gpcore
$ cd $home/openpiton
$ export PITON_ROOT=$PWD
$ source piton/piton_settings.bash
$ mkdir -p build/manycore/rel-0.1
$ ln -s manycore/rel-0.1/xsim.dir xsim.dir
$ touch diag.ev
```
### Running the tests on OpenPiton+AlexCore
```
$ sims -sys=manycore -vlt_build -vlt_build_args=--trace -vlt_build_args=-CFLAGS -vlt_build_args=-DVERILATOR_VCD -gpcore
$ sims -sys=manycore -gpcore -vlt_run test_name.S
//To debug_
//Generate asm commands from the hex to debug
$ riscv64-unknown-elf-objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data diag.exe > diag.dump
$ gtkwave my_top.vcd

```

#### uProcessor Enhancements
These are enhancements to the uProcessor performance, they will be implemented based on the time available and priorities.
- Compressed Instructions. 
- Branch Prediction.
- Register Renaming.
- Virtual Memory.
- FPU.
- Vector instrs extension.

#### Contribution
We really encourage anyone to contribute to our core. Please contact Alaa Salman alaamohsalman@gmail.com for more info. Thanks!. 

#### Acknowledgement
Special Thanks to Jonathan balkind OpenPiton Head Architect for continuous support and guidance.

#### Sponsored by ICpedia
![alt text](https://github.com/alaasal/GPCore/blob/master/ICpedia.PNG)
