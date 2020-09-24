module issue_stage (
	input logic clk, nrst,
	input logic we,			// we enable for regfile
	input logic [1:0] B_SEL, 	// B_SEL for op_b or immediates
	input logic wb_d,		// data to be written in regfile
	input logic [31:0] inst,	// input from IF stage (inst mem)
	output logic [31:0] op_a, op_b	// operands A & B output from regfile in PIPE #3 (to exe stage)
	);

	// registers
	logic [31:0] instr;	// pipe #3 from inst mem to decode stage and regfile

	// wires
	logic [4:0]  src_a, src_b; // addresses of required op_a & op_b from reg file
	logic [4:0]  dest;         // address of destenation register to write back in reg file
	logic [4:0]  shamt;	   // shift amount immediate
	logic [31:0] imm;	   // immediate sign extended
	logic [31:0] a, b;   	   // operands value output from the register file

	// PIPE
	always_ff @(posedge clk, negedge nrst)
	  begin
		if (!nrst)
			instr <= 0;
		else
			instr <= inst;
	  end


	// decoding instructions
	assign src_a = instr[19:15];
	assign src_b = instr[24:20];
	assign dest  = instr[11:7];
	assign shamt = instr[24:20];
	assign imm   = 32'(signed'(instr[31:20]));  // sign extended immediate to 32-bit

	// register file
	regfile reg1 (.clk(clk), .clrn(nrst), .we(we), .write_addr(dest), .source_a(src_a), .source_b(src_b), .result(wb_d),
			.op_a(a), .op_b(b));

	// assign op_a and op_b outputs
	assign op_a = a;

	// mux to select between operand b from regfile or sign extended 32-bit immediate (imm) or shamt imm
	always_comb
	  begin
		unique case(B_SEL)
			00: op_b = b;
			01: op_b = imm;
			10: op_b = shamt;
			default: op_b = b;
		endcase
	  end

endmodule
