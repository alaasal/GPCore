module instdec_stage(
	input logic clk, nrst,
	input logic  [31:0] instr,	  // input from frontend stage (inst mem)

	output logic [4:0] rs1, rs2, rd,  // op and dest registers addresses
	output logic [4:0] shamt,	  // shift amount imm
	output logic [11:0] imm,	  // immediate
	output logic we, pcselect, fn,	  // control signals
	output logic [1:0] B_SEL,
	output logic [4:0] alu_fn
	);

	// wires
	logic [6:0] opcode;
	logic [2:0] funct3;
	logic instr_30;
	
	// registers
	logic [31:0] instrReg3;	// pipe #3 from inst mem to decode stage
	
	// PIPE
	always_ff @(posedge clk, negedge nrst)
	  begin
		if (!nrst)
			instrReg3 <= 0;
		else
			instrReg3 <= instr;
	  end

	// output
	// decoding instructions
	assign opcode   = instr[6:0];
	assign funct3   = instr[14:12];
	assign instr_30 = instr[30];
	assign rs1      = instr[19:15];
	assign rs2      = instr[24:20];
	assign rd       = instr[11:7];
	assign shamt    = instr[24:20];
	assign imm      = 32'(signed'(instr[31:20]));  // sign extended immediate to 32-bit
	
	// instantiate controller
	instr_decoder c1 (.op(opcode), .funct3(funct3), .instr_30(instr_30), .pcselect(pcselect), .we(we), .B_SEL(B_SEL),
			 .alu_fn(alu_fn), .fn(fn));


endmodule
