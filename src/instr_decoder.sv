module instr_decoder(
	input logic [6:0] op,
	input logic [2:0] funct3,
	input logic [6:0] funct7,
	input logic [11:0]funct12,
	input logic instr_30,		// instr[30]
	// from commit stage
	input logic exception_pending,
	input logic TSR,
	input logic illegal_flag,

	input logic nrst,
	// Operands Select Sginals
	output logic [1:0] B_SEL,	// select op b

	// Write back Enable
	output logic we,

	// Function Control Signals
	output logic [2:0] fn,		// select result to be written back in regfile
	output logic [3:0] alu_fn,	// select alu operation

	// Branch, Jumps decode signals
	output logic j, jr,
	output logic bneq, 		        // to alu beq ~ bneq
	output logic btype,

	//Other Instrs decode signals
	output logic LUI, auipc,

	// Memory Decode Signals
	output logic [3:0] mem_op,  //mem operation type

	// Multiplier Decode Signals
	output logic [3:0] mulDiv_op,

	// Program Counter Select Piped to Execute Unit
	// until Branch and Jumps target is calculated
	output logic [1:0] pcselect,

	output logic ecall, ebreak, uret, sret, mret, wfi, illegal_instr,

	// Write back csr_regfile Enable
	output logic csr_we
    );

    	// Wires
	// Instruction Type
	logic rtype;		// Register Register Instructions
	logic itype; 		// Register Immediate Instructions (Arithmetic - Load )
	logic stype;		// Store Instructions
	logic jtype;		// Jump and add $PC Instructions
	logic jrtype;		// Jump and add $Reg Instructions
	logic utype;		// LUI Instruction
	logic autype;		// AUIPC Instruction

	// Arithemtic Register Register Instructions
	logic  i_add, i_sub, i_sll, i_slt, i_sltu, i_xor, i_srl, i_sra, i_or, i_and;

	// MulDiv Operations
	logic i_mul , i_mulh , i_mulhsu , i_mulhu , i_div ,i_divu, i_rem , i_remu, instr_25;

	// Arithemtic Immediate Instructions
	logic i_addi, i_slti, i_sltiu, i_xori, i_ori, i_andi, i_slli, i_srli, i_srai;

	// Branch Instructions
	logic BEQ, BNE, BLT, BGE, BLTU, BGEU;

	// Jump and add $PC Instruction
	logic i_jal;

	// Jump and add $Reg Instruction
	logic i_jalr;

	// Other Instructions
	logic lui,aupc;
	logic noOp;



	assign instr_25 = ~(& funct7[6:1]) & funct7[0];     //funct7 == 0000_001
	//noOp
	assign noOp = ~(|op); // if op code = 000000 then set opcode0 to 1
	// decode instructions							                                // opcode
	assign rtype = (~op[6]) & op[5] & op[4] & (~op[3]) & (~op[2]) & op[1] & op[0];  // 0110011
	assign itype = ~op[6] & ~op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0];       // 0010011
	assign btype = op[6] & op[5] & (~op[4]) & (~op[3]) & (~op[2]) & op[1] & op[0];  // 1100011
	//jump opcode decoding
	assign jtype  = op[6] & op[5] & (~op[4]) & op[3] & op[2] & op[1] & op[0];		//1101111 JAL
	assign jrtype = op[6] & op[5] & (~op[4]) & (~op[3]) & op[2] & op[1] & op[0];	//1100111 JALR
	//load
	assign ltype  = ~op[6] & ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];     //0000011
	//store
	assign stype  = ~op[6] & op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];      //0100011
	assign autype = ~op[6] & ~op[5] & op[4] & (~op[3]) & op[2] & op[1] & op[0];     //0110111 auipc
	assign utype = ~op[6] & op[5] & op[4] & (~op[3]) & op[2] & op[1] & op[0];    //0010111 LUI

	// zicsr and system instructions
	// interrupts and exceptions instructions
	assign system = op[6] & op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0];  //1110011 SYSTEM
	assign ecall  = system & (~|funct3) &  (~|funct12);
	assign ebreak = system & (~|funct3) &  funct12[0] & (~|funct7);
	assign uret   = system & (~|funct3) &  (~funct7[4]) & (~funct7[3]) & funct12[1];
	assign sret   = system & (~|funct3) &  (~funct7[4]) & funct7[3] & funct12[1] & ~TSR;
	assign mret   = system & (~|funct3) &  funct7[4] & funct7[3] & funct12[1];
	assign wfi    = system & (~|funct3) &  funct12[0] & funct12[2] & funct12[8];
	assign sfence = system & (~|funct3) &  funct7[0] & funct7[3];
	assign illegal_instruction = !(rtype || itype || btype || jtype || jrtype || ltype || stype || utype || autype || system 
	                           ||	(op[0] || op[1]) || (op == 7'h0F) || wfi || sfence) & illegal_flag; // ~(|op)

  assign illegal_sret = system & (~|funct3) &  (~funct7[4]) & funct7[3] & funct12[1] & TSR;
  assign illegal_instr = illegal_instruction || illegal_sret;
  
	// rtype op								  // instr[30] funct3
	assign i_add  = rtype & ~instr_30 & ~(|funct3);				  //   	0	000
	assign i_sub  = rtype &  instr_30 & ~(|funct3);				  //   	1	000
	assign i_sll  = rtype & ~instr_30 & ~funct3[2] & ~funct3[1] &  funct3[0];  //   0	001
	assign i_slt  = rtype & ~instr_30 & ~funct3[2] &  funct3[1] & ~funct3[0];  //   0	010
	assign i_sltu = rtype & ~instr_30 & ~funct3[2] &  funct3[1] &  funct3[0];  //   0	011
	assign i_xor  = rtype & ~instr_30 &  funct3[2] & ~funct3[1] & ~funct3[0];  //   0	100
	assign i_srl  = rtype & ~instr_30 &  funct3[2] & ~funct3[1] &  funct3[0];  //   0	101
	assign i_sra  = rtype &  instr_30 &  funct3[2] & ~funct3[1] &  funct3[0];  //   1	101
	assign i_or   = rtype & ~instr_30 &  funct3[2] &  funct3[1] & ~funct3[0];  //   0	110
	assign i_and  = rtype & ~instr_30 & (&funct3); 				  //   	0	111

	// rtype mul div                                                                  instr[25]  funct3
	assign i_mul    = rtype & instr_25 & ~(|funct3);                            //        0      000
	assign i_mulh   = rtype & instr_25 & ~funct3[2] & ~funct3[1] &  funct3[0];  //        0      001
	assign i_mulhsu = rtype & instr_25 & ~funct3[2] & funct3[1]  & ~funct3[0];  //        0      010
	assign i_mulhu  = rtype & instr_25 & ~funct3[2] & funct3[1]  & funct3[0];   //        0      011
	assign i_div    = rtype & instr_25 & funct3[2]  & ~funct3[1] & ~funct3[0];  //        0      100
	assign i_divu   = rtype & instr_25 &  funct3[2] & ~funct3[1] &  funct3[0];  //        0      101
	assign i_rem    = rtype & instr_25 & funct3[2]  & funct3[1]  & ~funct3[0];  //        0      110
	assign i_remu   = rtype & instr_25 & (&funct3);                             //        0      111

	// itype op
	assign i_addi  = itype & ~(|funct3);					  //   	x	000
	assign i_slti  = itype & ~funct3[2] &  funct3[1] & ~funct3[0];		  //	x	010
	assign i_sltiu = itype & ~funct3[2] &  funct3[1] &  funct3[0];		  //	x	011
	assign i_xori  = itype &  funct3[2] & ~funct3[1] & ~funct3[0];		  //	x	100
	assign i_ori   = itype &  funct3[2] &  funct3[1] & ~funct3[0];		  //	x	110
	assign i_andi  = itype & (&funct3);					  //	x	111
	assign i_slli  = itype & ~instr_30  & ~funct3[2] & ~funct3[1] & funct3[0]; //	0	001
	assign i_srli  = itype & ~instr_30  &  funct3[2] & ~funct3[1] & funct3[0]; //	0	101
	assign i_srai  = itype &  instr_30  &  funct3[2] & ~funct3[1] & funct3[0]; //	1	101

	// btype o
	assign BEQ  = btype & ~(|funct3);		  //   	x	000
	assign BNE  = btype & ~funct3[2] &  ~funct3[1] & funct3[0];		  //	x	001
	assign BLT  = btype & funct3[2] &  ~funct3[1] &  ~funct3[0];		  //	x	100
	assign BGE  = btype &  funct3[2] & ~funct3[1] & funct3[0];		  //	x	101
	assign BLTU = btype &  funct3[2] &  funct3[1] & ~funct3[0];		  //	x	110
    	assign BGEU = btype & (&funct3);					  //	x	111

	//jmp op
	assign i_jal	= jtype;
	assign i_jalr	= jrtype & ~(|funct3);


	//utype op
	assign lui         = utype;

	//autype op
	assign aupc        = autype;


	//load/store op
	assign i_lb  = ltype & ~funct3[2] & ~funct3[1] & ~funct3[0];    //000
	assign i_lh  = ltype & ~funct3[2] & ~funct3[1] & funct3[0];     //001
	assign i_lw  = ltype & ~funct3[2] & funct3[1]  & ~funct3[0];    //010
	assign i_lbu = ltype & funct3[2]  & ~funct3[1] & ~funct3[0];    //100
	assign i_lhu = ltype & funct3[2]  & ~funct3[1] & funct3[0];     //101

	assign i_sb = stype & ~funct3[2] & ~funct3[1] & ~funct3[0];     //000
	assign i_sh = stype & ~funct3[2] & ~funct3[1] & funct3[0];      //001
	assign i_sw = stype & ~funct3[2] & funct3[1] & ~funct3[0];      //010


	// =============================================== //
	//			 Outputs		   //
	// =============================================== //

    //mem_op
    //mem_op[3]   -> store = 1, load = 0
    //mem_op[2:1] -> word = 11, half = 01, byte = 10
    //mem_op[0]   -> signed = 1, unsigned = 0

    /*
    --------------------|
    mem_op  | operation |
    --------------------|
    4'b0000 | no_mem_op |
    4'b1111 | SW        |
    4'b1011 | SH        |
    4'b1101 | SB        |
    4'b0111 | LW        |
    4'b0011 | LH        |
    4'b0010 | LHU       |
    4'b0101 | LB        |
    4'b0100 | LBU       |
    --------------------|
    */

    assign mem_op[0] = i_sw | i_sh | i_sb | i_lw | i_lh | i_lb; //sign
	assign mem_op[1] = i_sw | i_sh | i_lw | i_lh | i_lhu;       //size
	assign mem_op[2] = i_sw | i_sb | i_lw | i_lb | i_lbu;               //size
	assign mem_op[3] = i_sw | i_sb  | i_sh;                     //store op

    // generate control signals
    assign pcselect[0] = 0 ; // to set pcselect to 0 (will be edited when branch and jump operations added)
    assign pcselect[1] = btype | i_jal | i_jalr;

    //00 rtype itype nop
    //01
    //10 branch
    //11
    assign we 	    = rtype | itype | jtype | jr | ltype| utype | autype | (system & ~(exception_pending));		  // set we to 1 if instr is rtype or itype (1 for all alu op)
		assign csr_we   = system;
		assign B_SEL[0] = i_addi | i_slti | i_sltiu | i_xori | i_ori | i_andi | i_jalr | ltype;
    assign B_SEL[1] = i_slli | i_srli | i_srai;


	// inst signal controls the type of instruction done by the ALU {bit30, funct3}
	// 0000 -> add | addi
	// 0001 -> SLL | slli
	// 0010 -> SLT | slti  | BLT
	// 0011 -> SLTU| sltiu | BLTU
	// 0100 -> xor | xori
	// 0101 -> SRL | srli
	// 0110 -> or  | ori
	// 0111 -> and | andi
	// 1000 -> sub | bneq  | beq
	// 1001 -> bge
	// 1010 -> bgeu
	// 1101 -> sra | srai

	assign alu_fn[0] = i_sll | i_slli| i_sltu | i_sltiu | i_srl | i_srli | i_and | i_andi | i_sra | i_srai | BLTU | BGE ;
	assign alu_fn[1] = i_slt | i_slti| i_sltu | i_sltiu | i_or  | i_ori  | i_and | i_andi | BLTU | BLT | BGEU ;
	assign alu_fn[2] = i_xor | i_xori| i_srl  | i_srli  | i_or  | i_ori  | i_and | i_andi| i_sra | i_srai;
	assign alu_fn[3] = i_sub | i_sra | i_srai | BEQ | BNE | BGE  | BGEU ;

    /*
    mulDiv_op
    mulDiv_op[3]    -> mul[h][s][u] = 0, div[u]/rem[u] = 1
    mulDiv_op[2]    -> div/mul = 0, mulh[s][u]/rem[u] = 1
    mulDiv_op[1:0]  -> signed = 1, unsigned = 3,
    ----------------------|
    mulDiv_op | operation |
    ----------------------|
    4'b0000   | no_op     |
    4'b0011   | MUL       |
    4'b0101   | MULH      |
    4'b0111   | MULHU     |
    4'b0110   | MULHSU    |
    4'b1001   | DIV       |
    4'b1011   | DIVU      |
    4'b1101   | REM       |
    4'b1111   | REMU      |
    ----------------------|
    */

	assign mulDiv_op[0] =  i_mul | i_mulh  | i_mulhu | i_div | i_divu | i_rem | i_remu;
	assign mulDiv_op[1] =  i_mul | i_mulhu | i_mulhsu| i_divu| i_remu;
	assign mulDiv_op[2] =  i_mulh| i_mulhu | i_mulhsu| i_rem | i_remu;
    assign mulDiv_op[3] =  i_div | i_divu  | i_rem   | i_remu;

	assign bneq = BNE ;
	assign j = i_jal;
	assign jr = i_jalr;
	assign LUI = lui;
	assign auipc = aupc;

	// =============================================== //
	//		Function Unit Decoder		   //
	// =============================================== //
	// 000 -> alu
	// 001 -> pc + 4
	// 010 -> m output
	// 011 -> immediate
	// 100 -> auipcimm
	// 111 -> load
	assign fn[0] = i_jal | i_jalr | lui | aupc ;
	assign fn[1] = i_mul | i_mulh | i_mulhsu | i_mulhu | i_rem | i_remu | i_div | i_divu | lui | system;
	assign fn[2] = ltype| aupc | system;		// to set fn to 0 (will be edited when branch, jump, mul/div operations added)
endmodule
