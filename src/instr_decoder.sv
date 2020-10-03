module instr_decoder(
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic instr_30,		// bit 30 in the instruction

    output logic [1:0] pcselect,// select pc source
    output logic we,		    // regfile write enable
    output logic [1:0] B_SEL,	// select op b
    output logic [3:0] alu_fn,	// select alu operation
    output logic [3:0]fn,		// select result to be written back in regfile
    output logic bneq, btype,	// to alu beq ~ bneq  
    output logic j, jr, LUI,auipc,       //JAL, JALR instructions
    output logic [4:0] mem_op  //mem operation type
    );

    // wires
    logic rtype, itype, i_add, i_sub, i_sll, i_slt, i_sltu, i_xor, i_srl, i_sra, i_or, i_and;
    logic i_addi, i_slti, i_sltiu, i_xori, i_ori, i_andi, i_slli, i_srli, i_srai;
    logic BEQ, BNE, BLT, BGE, BLTU, BGEU;
    logic noOp;
    logic jtype, jrtype, i_jal, i_jalr,utype,autype,lui,aupc ;

    //noOp
    assign noOp = ~(|op); // if op code = 000000 then set opcode0 to 1
    // decode instructions							                                // opcode
    assign rtype = (~op[6]) & op[5] & op[4] & (~op[3]) & (~op[2]) & op[1] & op[0];  // 0110011
    assign itype = ~op[6] & ~op[5] & op[4] & ~op[3] & ~op[2] & op[1] & op[0];       // 0010011
    assign btype = op[6] & op[5] & (~op[4]) & (~op[3]) & (~op[2]) & op[1] & op[0];  // 1100011
    //jump opcode decoding
    assign jtype  = op[6] & op[5] & (~op[4]) & op[3] & op[2] & op[1] & op[0];		//1101111 JAL
    assign jrtype = op[6] & op[5] & (~op[4]) & (~op[3]) & op[2] & op[1] & op[0];	//1100111 JALR
    assign utype = ~op[6] & ~op[5] & op[4] & (~op[3]) & op[2] & op[1] & op[0];		//0010111 LUI
    assign autype = ~op[6] & op[5] & op[4] & (~op[3]) & op[2] & op[1] & op[0];       //0110111 auipc 
 
    //load
    assign ltype  = ~op[6] & ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];     //0000011
    //store
    assign stype  = ~op[6] & op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];      //0100011

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
    assign i_srai  = itype &  instr_30  &  funct3[2] & ~funct3[1] & funct3[0]; //	1	101 

    // btype op
    assign BEQ  = btype & (~&funct3);					  //   	x	000
    assign BNE  = btype & ~funct3[2] &  ~funct3[1] & funct3[0];		  //	x	001
    assign BLT  = btype & funct3[2] &  ~funct3[1] &  ~funct3[0];		  //	x	100
    assign BGE  = btype &  funct3[2] & ~funct3[1] & funct3[0];		  //	x	101
    assign BLTU = btype &  funct3[2] &  funct3[1] & ~funct3[0];		  //	x	110
    assign BGEU = btype & (&funct3);					  //	x	111

    //jmp op
    assign i_jal	= jtype;
    assign i_jalr	= jrtype & (~&funct3);

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
    
    //mem_op
    //4'b0000	//no memory operation
    //4'b0001   //i_lb
    //4'b0010	//i_lh
    //4'b0011	//i_lw
    //4'b0100	//i_lbu
    //4'b0101	//i_lhu
    //4'b1110	//i_sb
    //4'b1111	//i_sh
    //4'b1000   //i_sw
    assign mem_op[0] = i_lb  | i_lw  | i_lhu | i_sh; 
    assign mem_op[1] = i_lh  | i_lw  | i_sb  | i_sh;
    assign mem_op[2] = i_lbu | i_lhu | i_sb  | i_sh;
    assign mem_op[3] = i_sw  | i_sb  | i_sh;
         
    // generate control signals
    assign pcselect[0] = ~(rtype|itype|noOp) && ~btype; // to set pcselect to 0 (will be edited when branch and jump operations added)
    assign pcselect[1] = btype | i_jal | i_jalr;

    //00 rtype itype nop
    //01 
    //10 branch 
    //11
    assign we 	    = rtype | itype | jtype | jr | ltype | utype | autype;		  // set we to 1 if instr is rtype or itype (1 for all alu op)
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

    assign bneq = BNE ; 
    assign j = i_jal;
    assign jr = i_jalr;
    assign LUI = lui;
    assign auipc = aupc;

    assign fn[0] = ~(rtype|itype) | i_jal | i_jalr ;
    assign fn[1] = ~(rtype|itype);
    assign fn[2] = ltype;		// to set fn to 0 (will be edited when branch, jump, mul/div operations added)
    assign fn[3] = |lui | aupc;
 endmodule
