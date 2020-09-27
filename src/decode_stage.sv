module instdec_stage(
	input logic clk, nrst,
	input logic  [31:0] instr2,	  // input from frontend stage (inst mem)

	output logic [4:0] rs1, rs2,	  // op registers addresses
	output logic [4:0] rd3,  	  // dest address
	output logic [4:0] shamt,	  // shift amount imm
	output logic [11:0] imm,	  // immediate
	output logic we3, pcselect3, fn3, // control signals
	output logic [1:0] B_SEL3,
	output logic [3:0] alu_fn3
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
			instrReg3 <= instr2;
	  end

	// output
	// decoding instructions
	assign opcode   = instrReg3[6:0];
	assign funct3   = instrReg3[14:12];
	assign instr_30 = instrReg3[30];
	assign rs1      = instrReg3[19:15];
	assign rs2      = instrReg3[24:20];
	assign rd3      = instrReg3[11:7];
	assign shamt    = instrReg3[24:20];
	assign imm      = 32'(signed'(instrReg3[31:20]));  // sign extended immediate to 32-bit
	
	// instantiate controller
	instr_decoder c1 (.op(opcode), .funct3(funct3), .instr_30(instr_30), .pcselect(pcselect3), .we(we3), .B_SEL(B_SEL3),
			 .alu_fn(alu_fn3), .fn(fn3));


endmodule
