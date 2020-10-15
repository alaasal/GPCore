/* Module frontend			|	
----------------------------------------|
frontend - Pipe 1			|	
- Inputs				|
Branch decode signals			|
Debug Signals				|
- Outputs				|
Next Instruction			|
----------------------------------------|
Determines next program counter		|
- Inputes				|
Branch decode signals			|
- Outputs				|
PC					|
----------------------------------------|
frontend - Pipe 2			|
----------------------------------------|
Fetches new instruction			|
- Inputs				|
Program Counter				|
- Outputs				|
Instr associated with its program couter|
---------------------------------------*/



module frontend_stage(
	input logic clk, nrst,

	//Branch and Jumps Target
	input logic [1:0] PCSEL,		// pc select control signal from execute pipe 5
	input logic [31:0] target,		//Jumps and Branch Target from execute pipe 5
	
	//Outputs to next pipe
	output logic [31:0] pc2,	
	output logic [31:0] instr2,  	
  
	//DEBUG Signals from debug module to load a program instrs to 
	input logic DEBUG_SIG,				 
    	input logic [31:0] DEBUG_addr,
	input logic [31:0] DEBUG_instr,
    	input logic clk_debug
    );

	// Registers
	logic [31:0] pcReg; 	   // pipe #1 pc
	logic [31:0] pcReg2;	   // pipe #2 from pc to inst mem

	// Wires
	logic [31:0] pc;		//Program Counter
	logic [31:0] npc;   	   // Next program counter

	// =============================================== //
	//			Pipe 1			   //
	// =============================================== //

	assign pc  = pcReg;

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

	always_ff @(posedge clk, negedge nrst)
	begin
        if (!nrst)
	  begin
		pcReg <= 0;
	  end
        else
          begin
		pcReg <= npc;		
          end
	end

	// =============================================== //
	//			Pipe 2			   //
	// =============================================== //
	instr_mem m1 (
        .clk(clk),

        .addr(pc),
        .instr(instr2),
 		
        .DEBUG_SIG(DEBUG_SIG),	
        .DEBUG_addr(DEBUG_addr),
        .DEBUG_instr(DEBUG_instr),
        .clk_debug(clk_debug)
	); 


	always_ff @(posedge clk, negedge nrst)
	begin
	if (!nrst)
          begin
		pcReg2 <= 0;
          end
        else
          begin
		pcReg2 <= pcReg;	
          end
	end



	// =============================================== //
	//			 Outputs		   //
	// =============================================== //
	assign pc2 = pcReg2; 	// program counter associated with the output instruction will be piped to (EXE/MEM stage)
    

endmodule
