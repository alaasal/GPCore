module issue_stage (
	input logic clk, nrst,
	input logic we_c,			// we from commit stage
	input logic we_d, fn_d,			// we enable for regfile
	input logic [4:0] rdaddr,		// destenation address from commit stage to regfile
	input logic [1:0] B_SEL, 		// B_SEL for op_b or immediates
	input logic [3:0] alu_fn_d,		// alu control from decode stage
	input logic [31:0] wb_d,		// data to be written in regfile
	input logic [4:0] rs1, rs2, rd_d, 	// addresses of operands (to regfile)
	input logic [4:0] shamt,		
	input logic [11:0] imm,			// immediate sign extended
	output logic [31:0] op_a, op_b,		// operands A & B output from regfile in PIPE #4 (to exe stage)
	output logic [4:0] rd,
	output logic [3:0] alu_fn,		// alu control in issue stage
	output logic fn, we			// function selection ctrl in issue stage and write enable
	);

	// registers pipe #4
	logic [4:0] srcaReg4, srcbReg4, rdReg4;
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
			srcaReg4    <= 0;
			srcbReg4    <= 0;
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
			srcaReg4  <= rs1;
			srcbReg4  <= rs2;
			rdReg4  <= rd_d;
			shamtReg4 <= shamt;
			immdReg4  <= imm;
			BSELReg4  <= B_SEL;
			// pass alu, fn & we control signals through the pipe form decode to issue stage
			alufnReg4 <= alu_fn_d;
			fnReg4 	 <= fn_d;
			weReg4	 <= we_d;
		  end
	  end
	
	// register file
	regfile reg1 (.clk(clk), .clrn(nrst), .we(we_c), .write_addr(rdaddr), .source_a(srcaReg4), .source_b(srcbReg4), .result(wb_d),
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
	assign alu_fn = alufnReg4;
	assign rd     = rdReg4;
	assign fn     = fnReg4;
	assign we     = weReg4;
 
endmodule
