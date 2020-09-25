module mem_stage(
	input logic clk, nrst,
	input logic fn_e, we_e,
	input logic [31:0] alu_res, // inputs to mem stage (currently ALU result only)
	output logic [31:0] result, // final output that will be written back in register file PIPE #6
	output logic we
	);

	// registers
	logic [31:0] alu_result;
	logic fn_m, we_m;
	
	// PIPE
	always_ff @(posedge clk, negedge nrst)
	  begin
		if (!nrst)
		  begin
			alu_result <= 0;
			fn_m 	   <= 0;
			we_m 	   <= 0;
		  end
		else
		  begin
			alu_result <= alu_res;
			fn_m 	   <= fn_e;
			we_m 	   <= we_e;
		  end
	  end
	
	// output (will be replaced by mux to select between data) and the selection signal is fn_m
	assign result = alu_result;
	
	assign we = we_m;

endmodule
