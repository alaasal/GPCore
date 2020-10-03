# GPCore
## This is the base repo for our graduation project in AlexU 21 building Linux-capble RISCV SoC
### uProcessor Action Plan

![alt text](https://github.com/alaasal/GPCore/blob/master_sync/block_diagram.PNG?raw=true)

#### uProcessor Required Design
- Inorder Superscalar RV32IM
- Use scoreboard to stall on every hazards (Most simple fix) 
- Integrate uProcessor + OpenPiton (To leverage Caches and Atomic Operations) 
- Privileged ISA (User Mode) 
- Integration with OpenPiton

#### uProcessor Enhancements
These are enhancements to the uProcessor performance, they will be implemented based on the time available and priorities.
- Data bypassing
- Compressed Instructions 
- Branch Predictions
- Register Renaming
- Virtual Memory
- Building Caches
- Out of Order execution for execute stage
- FPU
- Vector instrs extension

#### Contribution
We really encourage anyone to contribute to our core. The RTL will be kind of solid by the end of November will al required features being implemnted and hopefully we will be able to run some linux batches. You can fork it, play with it, optimized it based on your interests, or contribute with an enhancement. We will always be active with all PRs!. 

