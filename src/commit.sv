module commit_stage(
	input logic clk, nrst,
	input logic we_m,
	input logic [31:0] result,  // input result from mem to commit stage
	output logic [31:0] wb_data // final output that will be written back in register file PIPE #7
	);

	// registers
	logic [31:0] wb;
	logic we_c;
	
	// PIPE
	always_ff @(posedge clk, negedge nrst)
	  begin
		if (!nrst)
		  begin
			wb   <= 0;
			we_c <= 0;
		  end
		else
		  begin
			wb   <= result;
			we_c <= we_m;
		  end
	  end

	// output
	assign wb_data = wb;


endmodule
