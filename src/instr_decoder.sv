module controller(
	input logic [6:0] op,
	input logic [2:0] funct3,
	input logic instr_30,		// bit 30 in the instruction
	output logic pcselect,		// select pc source
	output logic we,		// regfile write enable
	output logic [1:0] B_SEL,	// select op b
	output logic [4:0] alu_fn,	// select alu operation
	output logic fn			// select result to be written back in regfile
	);

	// wires
	logic rtype, itype, i_add, i_sub, i_sll, i_slt, i_sltu, i_xor, i_srl, i_sra, i_or, i_and;
	logic i_addi, i_slti, i_sltiu, i_xori, i_ori, i_andi, i_slli, i_srli, i_srai;
	
	logic opcode0;
	assign opcode0 = ~(|op); // if op code = 000000 then set opcode0 to 1
	
	// decode instructions							  // opcode
	assign rtype = (~op[6]) & op[5] & op[4] & (~op[3]) & (~op[2]) & op[1] & op[0];  // 0110011
	assign itype = ~op[6] & ~op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0];  // 0010011
	// rtype op								  // instr[30] funct3
	assign i_add  = rtype & ~instr_30 & (~&funct3);				  //   	0	000
	assign i_sub  = rtype &  instr_30 & (~&funct3);				  //   	1	000
	assign i_sll  = rtype & ~instr_30 & ~funct3[2] & ~funct3[1] &  funct3[0];  //   0	001
	assign i_slt  = rtype & ~instr_30 & ~funct3[2] &  funct3[1] & ~funct3[0];  //   0	010
	assign i_sltu = rtype & ~instr_30 & ~funct3[2] &  funct3[1] &  funct3[0];  //   0	011
	assign i_xor  = rtype & ~instr_30 &  funct3[2] & ~funct3[1] & ~funct3[0];  //   0	100
	assign i_srl  = rtype & ~instr_30 &  funct3[2] & ~funct3[1] &  funct3[0];  //   0	101
	assign i_sra  = rtype &  instr_30 &  funct3[2] & ~funct3[1] &  funct3[0];  //   1	101
	assign i_or   = rtype & ~instr_30 &  funct3[2] &  funct3[1] & ~funct3[0];  //   0	110
	assign i_and  = rtype & ~instr_30 & (&funct3); 				  //   	0	111
	// itype op
	assign i_addi  = itype & (~&funct3);					  //   	x	000
	assign i_slti  = itype & ~funct3[2] &  funct3[1] & ~funct3[0];		  //	x	010
	assign i_sltiu = itype & ~funct3[2] &  funct3[1] &  funct3[0];		  //	x	011
	assign i_xori  = itype &  funct3[2] & ~funct3[1] & ~funct3[0];		  //	x	100
	assign i_ori   = itype &  funct3[2] &  funct3[1] & ~funct3[0];		  //	x	110
	assign i_andi  = itype & (&funct3);					  //	x	111
	assign i_slli  = itype & ~instr_30  & ~funct3[2] & ~funct3[1] & funct3[0]; //	0	001
	assign i_srli  = itype & ~instr_30  &  funct3[2] & ~funct3[1] & funct3[0]; //	0	101
	assign i_srai  = itype &  instr_30  &  funct3[2] & ~funct3[1] & funct3[0]; //	0	101

	// generate control signals
	assign pcselect = ~(rtype|itype|opcode0); // to set pcselect to 0 (will be edited when branch and jump operations added)
	assign we = rtype | itype;		  // set we to 1 if instr is rtype or itype (1 for all alu op)
	assign B_SEL[0] = i_addi | i_slti | i_sltiu | i_xori | i_ori | i_andi;
	assign B_SEL[1] = i_slli | i_srli | i_srai;
	
	// alu_fn value for each operation is defined in alu module
	assign alu_fn[0] = i_sub | i_or  | i_sll | i_sra | i_sltu | i_slti | i_xori | i_andi | i_srli;
	assign alu_fn[1] = i_and | i_or  | i_srl | i_sra | i_addi | i_slti | i_ori  | i_andi | i_srai;
	assign alu_fn[2] = i_xor | i_sll | i_srl | i_sra | i_sltiu| i_xori | i_ori  | i_andi;
	assign alu_fn[3] = i_slt | i_sltu| i_addi| i_slti| i_sltiu| i_xori | i_ori  | i_andi;
	assign alu_fn[4] = i_slli| i_srli| i_srai;

	assign fn = ~(rtype|itype);		// to set fn to 0 (will be edited when branch, jump, mul/div operations added)
endmodule
