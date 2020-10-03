module tb_instr_decoder;
reg [6:0] op;
reg [2:0] funct3;
reg instr_30;	        // bit 30 in the instruction
wire [1:0] pcselect;	// select pc source
wire we;	        // regfile write enable
wire [1:0] B_SEL;	// select op b
wire [3:0] alu_fn;	// select alu operation
wire  fn;		// select result to be written back in regfile
wire bneq,btype;        // to alu beq ~ bneq

// instantiate device under test
instr_decoder dut(.op(op), .funct3(funct3), .instr_30(instr_30), .pcselect(pcselect), .we(we), .B_SEL(B_SEL), .alu_fn(alu_fn), .fn(fn), .bneq(bneq), .btype(btype) );
// generate cases
 initial begin 
        op <= 7'b 0110011; //rtype ,we=1
	#40   funct3 = 3'b 000; instr_30 = 1'b 0; //i_add
        #50   funct3 = 3'b 000; instr_30 = 1'b 1; //i_sub
        #60   funct3 = 3'b 001; instr_30 = 1'b 0; //i_sll
        #70   funct3 = 3'b 010; instr_30 = 1'b 0; //i_slt      
        #80   funct3 = 3'b 011; instr_30 = 1'b 0; //i_sltu
        #90   funct3 = 3'b 100; instr_30 = 1'b 0; //i_xor
	#100  funct3 = 3'b 101; instr_30 = 1'b 0; //i_srl 
        #110  funct3 = 3'b 101; instr_30 = 1'b 1; //i_sra
	#120  funct3 = 3'b 110; instr_30 = 1'b 0; //i_or
	#130  funct3 = 3'b 111; instr_30 = 1'b 0; //i_and
	op = 7'b 0010011; //itype ,we=1
	#140  funct3 = 3'b 000; instr_30 =1'bx; //i_addi
        #160  funct3 = 3'b 010; instr_30 =1'bx; //i_slti
        #170  funct3 = 3'b 011; instr_30 = 1'bx; //i_sltiu
        #180  funct3 = 3'b 100; instr_30 = 1'bx; //i_xori    
        #190  funct3 = 3'b 110; instr_30 = 1'bx; //i_ori
        #200  funct3 =  3'b 111; instr_30 = 1'bx; //i_andi
	#210  funct3 = 3'b 001; instr_30 = 1'b 0; //i_slli   
        #220  funct3 = 3'b 101; instr_30 = 1'b 0; //i_srli
	#230  funct3 = 3'b 101; instr_30 = 1'b 1; //i_srai
	op = 7'b 1100011; //btype
	#240  funct3 = 3'b 000; instr_30 = 1'bx; //BEQ
	#250  funct3 = 3'b 001; instr_30 = 1'bx; //BNQ
        #260  funct3 = 3'b 100; instr_30 = 1'bx; //BLT
	#270  funct3 = 3'b 101; instr_30 = 1'bx; //BGE    
        #280  funct3 = 3'b 110; instr_30 = 1'bx; //BLTU
	#290  funct3 = 3'b 111; instr_30 = 1'bx; //BGEU
end

endmodule
