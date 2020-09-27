module issue_stage (
	input logic clk, nrst,
	input logic we6,			// we from commit stage pipe #6
	input logic we3, fn3,			// we enable for regfile & fn for result selection (from pipe #3)
	input logic [4:0] rdaddr6,		// destenation address from commit stage to regfile
	input logic [1:0] B_SEL3, 		// B_SEL for op_b or immediates
	input logic [3:0] alu_fn3,		// alu control from decode stage
	input logic [31:0] wb6,			// data to be written in regfile
	input logic [4:0] rs1, rs2,		// addresses of operands (to regfile)	
	input logic [4:0] rd3,			// rd address will be pipelined to commit stage
	input logic [4:0] shamt,		
	input logic [11:0] imm,			// immediate sign extended
	output logic [31:0] op_a, op_b,		// operands A & B output from regfile in PIPE #4 (to exe stage)
	output logic [4:0] rd4,
	output logic [3:0] alu_fn4,		// alu control in issue stage
	output logic fn4, we4			// function selection ctrl in issue stage and write enable
	);

	// registers pipe #4
	logic [4:0] rdReg4;
	logic [4:0] shamtReg4;
	logic [11:0] immdReg4;
	logic [1:0] BSELReg4;	
	logic [3:0] alufnReg4;	
	logic fnReg4;
	logic weReg4;

	// wires
	logic [31:0] a, b;   	   // operands value output from the register file
	
	// PIPE
	always_ff @(posedge clk, negedge nrst)
	  begin
		if (!nrst)
		  begin
			rdReg4      <= 0;
			shamtReg4   <= 0;
			immdReg4    <= 0;
			BSELReg4    <= 0;
			alufnReg4   <= 0;
			fnReg4 	    <= 0;
			weReg4	    <= 0;
		  end
		else
		  begin
			rdReg4  <= rd3;
			shamtReg4 <= shamt;
			immdReg4  <= imm;
			BSELReg4  <= B_SEL3;
			// pass alu, fn & we control signals through the pipe form decode to issue stage
			alufnReg4 <= alu_fn3;
			fnReg4 	 <= fn3;
			weReg4	 <= we3;
		  end
	  end
	
	// register file
	regfile reg1 (.clk(clk), .clrn(nrst), .we(we6), .write_addr(rdaddr6), .source_a(rs1), .source_b(rs2), .result(wb6),
			.op_a(a), .op_b(b));

	// assign op_a and op_b outputs
	assign op_a = a;

	// mux to select between operand b from regfile or sign extended 32-bit immediate (imm) or shamt imm
	always_comb
	  begin
		unique case(BSELReg4)
			00: op_b = b;
			01: op_b = immdReg4;
			10: op_b = shamtReg4;
			default: op_b = b;
		endcase
	  end

	// output
	assign alu_fn4 = alufnReg4;
	assign rd4     = rdReg4;
	assign fn4     = fnReg4;
	assign we4     = weReg4;
 
endmodule
