module core(
		input logic clk, nrst,
		// these outputs to observe the data flow in pipelines
		output logic [31:0] pc,      	// program counter PIPE #1
		output logic [31:0] pc_mem,   	// pc at instruction mem pipe #2
		output logic [31:0] inst,    	// instruction in PIPE #3
		output logic [31:0] op_a, op_b, // operands a & b in PIPE #4
	 	output logic [31:0] alu_res,    // alu result in PIPE #5
		output logic [31:0] result,	// result in PIPE #6
		output logic [31:0] wb_data	// data that will be written back PIPE #7
	);

	// wires
	logic [31:0] ins;   	   // output wire of IF stage
	logic [31:0] opa, opb;     // operands value output from issue stage
	logic [4:0] rs1, rs2, rd;
	logic [4:0] shamt;
	logic [11:0] imm;
	logic we_d, fn_d;
	logic we_i, fn_i;
	logic we_e, fn_e;
	logic we_m;
	logic pcselect;
	logic [1:0] B_SEL;
	logic [4:0] alu_fn_d;
	logic [4:0] alu_fn_i;
	logic [31:0] alu_result;   // alu result output from exe to mem stage
	logic [31:0] res;	   // result output from mem to commit stage
	logic [31:0] wb;	   // data output from commit stage to regfile to be written
	
	// instantiating stages (7 pipelines)
	IF_stage s1 (.clk(clk), .nrst(nrst), .PCSEL(pcselect), .pc(pc), .pc_mem(pc_mem), .inst(ins));

	instdec_stage s2 (.clk(clk), .nrst(nrst), .inst(ins), .rs1(rs1), .rs2(rs2), .rd(rd), .shamt(shamt), .imm(imm),
				.we(we_d), .pcselect(pcselect), .fn(fn_d), .B_SEL(B_SEL), .alu_fn(alu_fn_d));


	issue_stage s3 (.clk(clk), .nrst(nrst), .we_d(we_d), .fn_d(fn_d), .B_SEL(B_SEL), .alu_fn_d(alu_fn_d), .wb_d(wb),
			 .rs1(rs1), .rs2(rs2), .rd(rd), .shamt(shamt), .imm(imm), .op_a(opa), .op_b(opb), .alu_fn(alu_fn_i),
			 .fn(fn_i), .we(we_i));

	exe_stage s4 (.clk(clk), .nrst(nrst), .fn_i(fn_i), .we_i(we_i), .alu_fn_i(alu_fn_i), .op_a(opa), .op_b(opb),
			.alu_res(alu_result), .fn(fn_e), .we(we_e));

	mem_stage s5 (.clk(clk), .nrst(nrst), .fn_e(fn_e), .we_e(we_e), .alu_res(alu_result), .result(res), .we(we_m));

	commit_stage s6 (.clk(clk), .nrst(nrst), .we_m(we_m), .result(res), .wb_data(wb));
	
	// output
	assign inst = ins;
	assign op_a = opa;
	assign op_b = opb;
	assign alu_res = alu_result;
	assign result = res;
	assign wb_data = wb;

endmodule
