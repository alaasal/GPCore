# AlexCore
## This is the base repo for our graduation project in AlexU 21 building Linux-capable RISCV SoC
![alt text](https://github.com/alaasal/GPCore/blob/master_sync/block_diagram.PNG?raw=true)
![alt text](https://github.com/alaasal/GPCore/blob/master/AlexSoC.PNG?raw=true)

#### uProcessor Design
This is a 6 stage riscv 32 IM build originally to form a SoC with OpenPiton and to be optimized for cryptography by connecting a specific IP.
- In-order RV32IM.
- Use scoreboard to stall on every hazard (most simple fix).
- OpenPiton Integration (to leverage Caches and Atomic Operations). 
- Privileged ISA.
- Crypto IP.

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
