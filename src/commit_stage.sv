
module commit_stage(
	input logic clk, nrst,
	input logic we_m,
	input logic [4:0] rd_m,
	input logic [31:0] result,  // input result from mem to commit stage
	output logic [4:0] rd,
	output logic [31:0] wb_data // final output that will be written back in register file PIPE #7
	);

	// registers
	logic [31:0] wbReg7;
	logic weReg7;
	logic [4:0] rdReg7;
	
	// PIPE
	always_ff @(posedge clk, negedge nrst)
	  begin
		if (!nrst)
		  begin
			wbReg7 <= 0;
			weReg7 <= 0;
			rdReg7 <= 0;
		  end
		else
		  begin
			wbReg7 <= result;
			weReg7 <= we_m;
			rdReg7 <= rd_m;
		  end
	  end

	// output
	assign wb_data = wbReg7;
	assign rd = rdReg7;


endmodule