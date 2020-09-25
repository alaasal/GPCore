module issue_stage (
	input logic clk, nrst,
	input logic we_d, fn_d,			// we enable for regfile
	input logic [1:0] B_SEL, 		// B_SEL for op_b or immediates
	input logic [4:0] alu_fn_d,		// alu control from decode stage
	input logic [31:0] wb_d,		// data to be written in regfile
	input logic [4:0] rs1, rs2, rd, 	// addresses of operands (to regfile)
	input logic [4:0] shamt,		
	input logic [11:0] imm,			// immediate sign extended
	output logic [31:0] op_a, op_b,		// operands A & B output from regfile in PIPE #4 (to exe stage)
	output logic [4:0] alu_fn,		// alu control in issue stage
	output logic fn, we			// function selection ctrl in issue stage and write enable
	);

	// registers pipe #4
	logic [4:0] src_a, src_b, dest;
	logic [4:0] shamt_i;
	logic [11:0] immd_i;
	logic [1:0] B_SEL_i;	
	logic [4:0] alu_fn_i;	
	logic fn_i;
	logic we_i;

	// wires
	logic [31:0] a, b;   	   // operands value output from the register file
	
	// PIPE
	always_ff @(posedge clk, negedge nrst)
	  begin
		if (!nrst)
		  begin
			src_a    <= 0;
			src_b    <= 0;
			dest     <= 0;
			shamt_i  <= 0;
			immd_i   <= 0;
			B_SEL_i  <= 0;
			alu_fn_i <= 0;
			fn_i 	 <= 0;
			we_i	 <= 0;
		  end
		else
		  begin
			src_a	 <= rs1;
			src_b	 <= rs2;
			dest     <= rd;
			shamt_i  <= shamt;
			immd_i   <= imm;
			B_SEL_i  <= B_SEL;
			// pass alu, fn & we control signals through the pipe form decode to issue stage
			alu_fn_i <= alu_fn_d;
			fn_i 	 <= fn_d;
			we_i	 <= we_d;
		  end
	  end
	
	// register file
	regfile reg1 (.clk(clk), .clrn(nrst), .we(we), .write_addr(dest), .source_a(src_a), .source_b(src_b), .result(wb_d),
			.op_a(a), .op_b(b));

	// assign op_a and op_b outputs
	assign op_a = a;

	// mux to select between operand b from regfile or sign extended 32-bit immediate (imm) or shamt imm
	always_comb
	  begin
		unique case(B_SEL_i)
			00: op_b = b;
			01: op_b = immd_i;
			10: op_b = shamt_i;
			default: op_b = b;
		endcase
	  end

	// output
	assign alu_fn = alu_fn_i;
	assign fn     = fn_i;
	assign we     = we_i;
 
endmodule
