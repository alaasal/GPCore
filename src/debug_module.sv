module debug(
	input logic clk,
	input logic nrst,
	

	output logic DEBUG_SIG,				//DEBUG Signals from debug module to load a program
	output logic [31:0] DEBUG_addr,
	output logic [31:0] DEBUG_instr,
	output logic START
);


parameter NUM_Of_INSTRS = 355;
logic [31:0] instrs[354:0];
initial $readmemh("instruction.txt", instrs);

logic [9:0] instrs_index;

	always_ff @(posedge clk, negedge nrst)
	  begin
		if (!nrst)
		  begin
			DEBUG_SIG <= 0;
			DEBUG_addr <= 32'h70;
			instrs_index <= 0;
			DEBUG_instr <= instrs[0];
			START <= 0;
		  end
		else
		  begin
			DEBUG_instr <= instrs[instrs_index];
			instrs_index <= instrs_index + 1;		
			DEBUG_addr <= DEBUG_addr + 3'b100;
			START <= (instrs_index > (NUM_Of_INSTRS) ) ;
			DEBUG_SIG <= ~(instrs_index == (NUM_Of_INSTRS));
		  end
	  end
	

endmodule

	