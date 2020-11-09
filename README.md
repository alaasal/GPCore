# GPCore
## This is the base repo for our graduation project in AlexU 21 building Linux-capable RISCV SoC
### uProcessor Action Plan

![alt text](https://github.com/alaasal/GPCore/blob/master_sync/block_diagram.PNG?raw=true)

#### uProcessor Required Design
- In-order Superscalar RV32IM.
- Use scoreboard to stall on every hazard (most simple fix).
- Integrate uProcessor + OpenPiton (to leverage Caches and Atomic Operations). 
- Privileged ISA (user Mode).
- Integration into OpenPiton.

#### uProcessor Enhancements
These are enhancements to the uProcessor performance, they will be implemented based on the time available and priorities.
- Data bypassing.
- Compressed Instructions. 
- Branch Prediction.
- Register Renaming.
- Virtual Memory.
- Building Caches.
- Out of Order execution for execute stage.
- FPU.
- Vector instrs extension.

#### Contribution
We really encourage anyone to contribute to our core. The RTL will be kind of solid by the end of November will all required features implemented and, hopefully, we will be able to run some Linux batches. You can fork it, play with it, optimize it based on your interests, or contribute with an enhancement. We will always be active with all PRs!. 

