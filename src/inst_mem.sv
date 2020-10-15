module instr_mem (
	input clk,

	input  logic [31:0] addr, 
                  
	output logic [31:0] instr,                

	//DEBUG Signals from debug module to load a program
	input logic DEBUG_SIG,				
	input logic [31:0] DEBUG_addr,
	input logic [31:0] DEBUG_instr,
	input logic clk_debug
);


	logic[31:0] rom [99:0];		//mem defintion as associative array
 
	always_ff @(posedge clk_debug)
	  begin
		if (DEBUG_SIG)
		  begin
			rom[DEBUG_addr] = DEBUG_instr;
		  end
	  end
        always_ff @(posedge clk)
	  begin
		instr = rom[addr];
	  end
endmodule
