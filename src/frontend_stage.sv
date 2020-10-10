module frontend_stage(
    input logic clk, nrst,
    input logic clk, nrst,stall,
    input logic [1:0] PCSEL,		// pc select control signal
    input logic [31:0] target,

    output logic [31:0] pc2,	// pc at instruction mem pipe #2
    output logic [31:0] instr2,  	// instruction output from inst memory (to decode stage)
    
    //Just for testing not an actual output
    output logic [31:0] pc,		// program counter PIPE #1

    input logic DEBUG_SIG,				//DEBUG Signals from debug module to load a program
    input logic [31:0] DEBUG_addr,
    input logic [31:0] DEBUG_instr,
    input logic clk_debug
    );

    // registers
    logic [31:0] pcReg; 	   // pipe #1 pc
    logic [31:0] pcReg2;	   // pipe #2 from pc to inst mem
    // wires
    logic [31:0] npc;   	   // next pc wire
    logic clk_front;
    
    assign clk_front = clk & (~stall);
    
    // pipes
    always_ff @(posedge clk, negedge nrst)
    always_ff @(posedge clk_front , negedge nrst)
      begin
        if (!nrst)
          begin
            pcReg		<= 0;
            pcReg2 		<= 0;
          end
        else
          begin
        else begin
            pcReg		<= npc;		// PIPE1
            pcReg2		<= pcReg;	// PIPE2
          end
      end

    always_comb
      begin
        // npc logic
        unique case(PCSEL)
            0: npc = pcReg + 1;
            1: npc = 0;
            2: npc = target;
            default: npc = pcReg + 1 ;
        endcase
      end

    // output
    assign pc  = pcReg;
    assign pc2 = pcReg2; 	// pc + 4 will be piped to (EXE/MEM stage)

    
    // dummy inst mem
    instr_mem m1 (
        .clk(clk),
        .clk(clk_front),
        .addr(pc),
        .instr(instr2), 		
        .DEBUG_SIG(DEBUG_SIG),				//DEBUG Signals from debug module to load a program
        .DEBUG_addr(DEBUG_addr),
        .DEBUG_instr(DEBUG_instr),
        .clk_debug(clk_debug)); 

endmodule
