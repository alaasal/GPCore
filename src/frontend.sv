module IF(
	input logic clk, nrst,
	input logic PCSEL,		// pc select control signal
	output logic [31:0] pc,		// program counter PIPE #1
	output logic [31:0] pc_mem,	// pc at instruction mem pipe #2
	output logic [31:0] inst  	// instruction output from memory inst memory (to decode stage)
	);

	// registers
	logic [31:0] pc_reg; 	   // pipe #1 pc
	logic [31:0] pcinst;	   // pipe #2 from pc to inst mem

	// wires
	logic [31:0] npc;   	   // next pc wire

	// pipes
	always_ff @(posedge clk, negedge nrst)
	  begin
		if (!nrst)
		  begin
			pc_reg <= 0;
			pcinst <= 0;
		  end
		else
		  begin
			pc_reg <= npc;		// PIPE1
			pcinst <= pc_reg;	// PIPE2
		  end
	  end

	always_comb
	  begin
		// npc logic
		unique case(PCSEL)
			0: npc = pc_reg + 4;
			1: npc = 0;
			default: npc = pc_reg + 4;
		endcase
	  end

	// output
	assign pc    = pc_reg;
	assign pc_mem = pcinst;

	// dummy inst mem
	inst_mem m1 (.a(pcinst), .inst(inst));  // output inst for decode stage

endmodule
