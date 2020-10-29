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

	logic[7:0] rom [1550:0];		//mem defintion as associative array
 
	always_ff @(posedge clk_debug)
	  begin
		if (DEBUG_SIG)
		  begin
			rom[DEBUG_addr] = DEBUG_instr[31:24];
			rom[DEBUG_addr+1] = DEBUG_instr[23:16];
			rom[DEBUG_addr+2] = DEBUG_instr[15:8];
			rom[DEBUG_addr+3] = DEBUG_instr[7:0];
			instr = 0;
		  end
	  end
        always_ff @(posedge clk)
	  begin
		instr <= {rom[addr],rom[addr+1],rom[addr+2],rom[addr+3]};
	  end
endmodule
