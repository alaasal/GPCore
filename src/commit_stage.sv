
module commit_stage(
	input logic clk, nrst,
	input logic we5,
	input logic [4:0] rd5,
	input logic [31:0] result5,   // input result from mem to commit stage
	output logic [4:0] rd6,
	output logic [31:0] wb_data6, // final output that will be written back in register file PIPE #6
	output logic we6
	);

	// output
	assign wb_data6 = result5;
	assign rd6 = rd5;
	assign we6 = we5;

endmodule
