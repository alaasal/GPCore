module exe_stage(
	input logic clk, nrst,
	input logic [31:0] op_a, op_b,	// operands a and b from issue stage
	output logic [31:0] alu_res  	// alu result in PIPE #4
	);
	
	// registers
	logic [31:0] e_opa;	   // pipe #4 from decode to execute stage (operand A at execute stage)
	logic [31:0] e_opb;	   // pipe #4 from decode to execute stage (operand B at execute stage)
	
	// *will be replaced by alu block* //
	assign alu_res = e_opa + e_opb;

	// pipes
	always_ff @(posedge clk, negedge nrst)
	  begin
		if (!nrst)
		  begin
			e_opa  <= 0;
			e_opb  <= 0;
		  end
		else
		  begin
			e_opa  <= op_a;		// PIPE4
			e_opb  <= op_b;		// PIPE4	
		  end
	  end

endmodule
