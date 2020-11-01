
class packet; // used for randomization of variables
	rand bit  we4_rand;
	rand bit  [2:0]   fn4_rand;
	rand bit  [4:0]   rd4_rand;
	rand bit  [3:0]   alu_fn4_rand;
	rand bit  [31:0]  op_a_rand, op_b_rand;
	rand bit  [31:0]  pc4_rand, B_imm4_rand, J_imm4_rand, U_imm4_rand, S_imm4_rand;
	rand bit  [1:0]   pcselect4_rand;
        rand bit  [2:0]   mulDiv_op4_rand;
        rand bit  [3:0]   mem_op4_rand;
	rand bit  j4_rand, jr4_rand, bneq4_rand, btype4_rand, LUI4_rand, auipc4_rand;  
endclass

`timescale 1ns/1ns
module tb_exe_stage;
        reg clk, nrst;

	reg [31:0] op_a;
 	reg [31:0] op_b;	
	reg [4:0] rd4;			// rd address from issue stage

	reg [2:0] fn4;
	reg [3:0] alu_fn4;

	reg we4;

	reg [31:0] B_imm4;
	reg [31:0] J_imm4;
	reg [31:0] U_imm4 ;
	reg [31:0] S_imm4;

	reg bneq4;
	reg btype4;
	
	reg j4;
	reg jr4;
	reg LUI4;
	reg auipc4;

	reg [3:0] mem_op4;
	reg [2:0] mulDiv_op4;

	reg [31:0] pc4;
	reg [1:0] pcselect4;

	wire [31:0] wb_data6;
	wire we6;

	wire [4:0] rd6;
	
	wire [31:0] U_imm6;
	wire [31:0] AU_imm6;
	
	wire [31:0] mem_out6;
	wire addr_misaligned6;

	wire [31:0] mul_divReg6;
	
	wire [31:0] target;
	wire [31:0] pc6;
	wire [1:0] pcselect5;
// instantiate device under test
 exe_stage dut(.clk(clk), .nrst(nrst), .fn4(fn4), .we4(we4), .bneq4(bneq4), .btype4(btype4), .rd4(rd4), .alu_fn4(alu_fn4), .op_a(op_a), .op_b(op_b), .pc4(pc4) , .B_imm4(B_imm4) ,  .J_imm4(J_imm4), .U_imm4(U_imm4), .S_imm4(S_imm4), .pcselect4(pcselet4) , .j4(j4), .jr4(jr4), .LUI4(LUI4), .auipc4(auipc4), .mem_op4(mem_op4) , .mulDiv_op4(mulDiv_op4), .wb_data6(wb_data6) , .we6(we6) , .rd6(rd6) , .U_imm6(U_imm6) , .AU_imm6(AU_imm6) , .mem_out6(mem_out6) , .addr_misaligned6(addr_misaligned6), .mul_divReg6(mul_divReg6) , .target(target), .pc6(pc6), .pcselect5(pcselect5) );

// generate clock
initial begin 
    clk =0; 
 end 
 always
 #5 clk = ~clk;

//stimulus generation 
 initial begin
    packet pkt;
    pkt = new(); 
     
     nrst = 0;
     #5  nrst = 1;
    
     repeat(10)begin
     pkt.randomize();

	fn4        =  pkt.fn4_rand;
	we4        =  pkt.we4_rand;
	bneq4      =  pkt.bneq4_rand ;
	btype4     =  pkt.btype4_rand ;
	rd4        =  pkt.rd4_rand ;
	alu_fn4    =  pkt.alu_fn4_rand ;
	op_a       =  pkt.op_a_rand ;
	op_b       =  pkt.op_b_rand ;
	pc4        =  pkt.pc4_rand ;
	B_imm4     =  pkt.B_imm4_rand  ;
	J_imm4     =  pkt.J_imm4_rand;
        U_imm4     =  pkt.U_imm4_rand;
        S_imm4     =  pkt.S_imm4_rand;
        LUI4       =  pkt.LUI4_rand;
        auipc4     =  pkt.auipc4_rand;
        mem_op4    =  pkt.mem_op4_rand;
        mulDiv_op4 =  pkt.mulDiv_op4_rand;
	pcselect4  =  pkt.pcselect4_rand ;
	j4         =  pkt.j4_rand  ;
	jr4        =  pkt.jr4_rand  ;
     
   
  end
   end 
endmodule

