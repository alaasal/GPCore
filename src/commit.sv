module commit_stage(
	input logic clk, nrst,
	input logic [31:0] result,  // input result from mem to commit stage
	output logic [31:0] wb_data // final output that will be written back in register file PIPE #5
	);

	// registers
	logic [31:0] wb;
	
	// PIPE
	always_ff @(posedge clk, negedge nrst)
	  begin
		if (!nrst)
			wb <= 0;
		else
			wb <= result;
	  end

	// output
	assign wb_data = wb;


endmodule
