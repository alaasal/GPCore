
module commit_stage(
	input logic clk, nrst,
	input logic we5,
	input logic [4:0] rd5,
	input logic [31:0] result5,   // input result from mem to commit stage
	output logic [4:0] rd6,
	output logic [31:0] wb_data6, // final output that will be written back in register file PIPE #6
	output logic we6
	);

	// registers
	logic [31:0] wbReg6;
	logic weReg6;
	logic [4:0] rdReg6;
	
	// PIPE
	always_ff @(posedge clk, negedge nrst)
	  begin
		if (!nrst)
		  begin
			wbReg6 <= 0;
			weReg6 <= 0;
			rdReg6 <= 0;
		  end
		else
		  begin
			wbReg6 <= result5;
			weReg6 <= we5;
			rdReg6 <= rd5;
		  end
	  end

	// output
	assign wb_data6 = wbReg6;
	assign rd6 = rdReg6;
	assign we6 = we6;

endmodule
