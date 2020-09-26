module exe_stage(
	input logic clk, nrst,
	input logic fn_i, we_i,
	input logic [4:0] rd_i,		// rd address from issue stage
	input logic [3:0] alu_fn_i,
	input logic [31:0] op_a, op_b,	// operands a and b from issue stage

	output logic [31:0] alu_res,  	// alu result in PIPE #5
	output logic [4:0] rd,
	output logic fn, we
	);
	
	// registers
	logic [31:0] opaReg5;	   // pipe #5 from decode to execute stage (operand A at execute stage)
	logic [31:0] opbReg5;	   // pipe #5 from decode to execute stage (operand B at execute stage)
	logic [3:0] alufnReg5;	   // alu control in exe stage will be input to alu block
	logic [4:0] rdReg5;
	logic fnReg5;		   
	logic weReg5;
	
	//ALU
	alu exe_alu (.alu_fn(alufnReg5), .operandA(opaReg5), .operandB(opbReg5), .result(alu_res));

	// pipes
	always_ff @(posedge clk, negedge nrst)
	  begin
		if (!nrst)
		  begin
			opaReg5   <= 0;
			opbReg5   <= 0;
			alufnReg5 <= 0;
			rdReg5	  <= 0;
			fnReg5	  <= 0;
			weReg5	  <= 0;
		  end
		else
		  begin
			opaReg5   <= op_a;
			opbReg5   <= op_b;	
			alufnReg5 <= alu_fn_i;
			rdReg5	  <= rd_i;
			fnReg5	  <= fn_i;
			weReg5	  <= we_i;
		  end
	  end

	// output
	assign rd = rdReg5;
	assign fn = fnReg5;
	assign we = weReg5;

endmodule
