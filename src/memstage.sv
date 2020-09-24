module mem_stage(
	input logic clk, nrst,
	input logic [31:0] alu_res, // inputs to mem stage (currently ALU result only)
	output logic [31:0] result  // final output that will be written back in register file PIPE #5
	);

	// registers
	logic [31:0] alu_result;
	
	// PIPE
	always_ff @(posedge clk, negedge nrst)
	  begin
		if (!nrst)
			alu_result <= 0;
		else
			alu_result <= alu_res;
	  end
	
	// output (will be replaced by mux to select between data)
	assign result = alu_result;

endmodule
