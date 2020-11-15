//this testbench is designed to test issue stage
class packet; // used for randomization of variables
  rand bit [4:0] rdaddr6_rand;
  rand bit we6_rand;
  rand bit we3_rand; 
  rand bit fn3_rand;
  rand bit  bneq3_rand;
  rand bit btype3_rand;
  rand bit [3:0] alu_fn3_rand;
  rand bit [31:0] wb6_rand;	
  rand bit [4:0] rs1_rand; 
  rand bit [4:0] rs2_rand;
  rand bit [4:0] rd3_rand;
  rand bit [4:0] shamt_rand;
  
  rand bit [31:0] I_imm3_rand; 
  rand bit [31:0] B_imm3_rand;
  rand bit [31:0] J_imm3_rand;
  rand bit [31:0] S_imm3_rand;
  rand bit [31:0] U_imm3_rand;
  
  rand bit [1:0] B_SEL3_rand;
  
  rand bit j3_rand;
  rand bit jr3_rand;
  rand bit LUI3_rand;
  rand bit auipc3_rand;
  rand bit [3:0] mem_op3_rand;
  rand bit [2:0] mulDiv_op3_rand;
  
  rand bit [31:0] pc3_rand;
  rand bit [1:0] pcselect3_rand;
  
endclass
 
`timescale 1ns/1ns 
module tb_issue; 
  
reg clk, nrst;
reg we6;			// we from commit stage pipe #6
reg [4:0] rdaddr6;		// destenation address from commit stage to regfile
reg [31:0] wb6;			// data to be written in regfile
reg we3, fn3 , bneq3,btype3;	// we enable for regfile & fn for result selection (from pipe #3)
reg [3:0] alu_fn3;		// alu control from decode stage
reg [4:0] rs1, rs2;		// addresses of operands (to regfile)	
reg [4:0] rd3;			// rd address will be pipelined to commit stage
reg [1:0] B_SEL3; 		// B_SEL for op_b or I_immediates	
reg [31:0] I_imm3,B_imm3,J_imm3,S_imm3,U_imm3;	// I_immediate sign extended
reg [4:0] shamt;	
reg j3;
reg jr3;
reg LUI3;
reg auipc3;
reg [3:0] mem_op3;
reg [2:0] mulDiv_op3;
reg [31:0] pc3;
reg [1:0] pcselect3;


wire [31:0] op_a;
wire [31:0] op_b;		
wire [4:0] rd4;
wire [3:0] alu_fn4;
wire [2:0] fn4;		
wire [31:0] B_imm4;
wire [31:0] J_imm4;
wire [31:0] S_imm4;
wire [31:0] U_imm4;
wire we4;
wire bneq4;
wire btype4;
wire j4;
wire jr4;
wire LUI4;
wire auipc4;
wire [3:0] mem_op4;
wire [2:0] mulDiv_op4;
wire [31:0] pc4;
wire [1:0] pcselect4;
	
//instantiation of DUT
 issue_stage DUT(.clk(clk), .nrst(nrst),.we6(we6),.rdaddr6(rdaddr6),.wb6(wb6),.we3(we3),.bneq3(bneq3),.btype3(btype3),.fn3(fn3) ,.alu_fn3(alu_fn3),
 .rs1(rs1),.rs2(rs2),.rd3(rd3),.B_SEL3(B_SEL3),.I_imm3(I_imm3),.B_imm3(B_imm3),.J_imm3(J_imm3),.S_imm3(S_imm3),.U_imm3(U_imm3),.shamt(shamt),
 .j3(j3),.jr3(jr3),.LUI3(LUI3),.auipc3(auipc3),.mem_op3(mem_op3),.mulDiv_op3(mulDiv_op3),.pc3(pc3),.pcselect3(pcselect3),
 
 .op_a(op_a),.op_b(op_b),.rd4(rd4),.alu_fn4(alu_fn4),.fn4(fn4),.B_imm4(B_imm4),.J_imm4(J_imm4),.S_imm4(S_imm4),.U_imm4(U_imm4), .we4(we4),.bneq4(bneq4),.btype4(btype4),
 .j4(j4),.jr4(jr4),.LUI4(LUI4),.auipc4(auipc4),.mem_op4(mem_op4),.mulDiv_op4(mulDiv_op4),
 .pc4(pc4),.pcselect4(pcselect4));

//clock  generation
initial begin 
    clk = 0; 
 end 
 always begin 
 #5 clk = ~clk;
  end
  

//stimulus generation 
 initial begin
    packet pkt;
    pkt = new(); 
     
	   nrst = 0;
#10  nrst = 1;
   repeat (15)begin
     pkt.randomize();
    
     rdaddr6 = pkt.rdaddr6_rand; // destenation address from commit stage to regfile 
     wb6 = pkt.wb6_rand;
     we6 = pkt.we6_rand;         // randomizing data written into regfile from commit stage
     rs1 = pkt.rs1_rand;
     rs2 = pkt.rs2_rand;
     
     // randomizing signals that are piped from pipe3 to pipe4
     rd3    = pkt.rd3_rand;         // should be equal to rd4
     shamt  = pkt.shamt_rand;    // should be equal to shmatreg4
     I_imm3 = pkt.I_imm3_rand; // to be muxed with operand B
     B_imm3 = pkt.B_imm3_rand; // should be equal to B_imm4 
     J_imm3	= pkt.J_imm3_rand;
	   U_imm3 = pkt.U_imm3_rand;
	   S_imm3 = pkt.S_imm3_rand;
	   
	   j3 = pkt.j3_rand;
	   jr3 = pkt.jr3_rand;
	   LUI3 = pkt.LUI3_rand;
	   auipc3 = pkt.auipc3_rand;

	   mem_op3 = pkt.mem_op3_rand;
	   mulDiv_op3 = pkt.mulDiv_op3_rand;
     
     pcselect3 = pkt.pcselect3_rand; // should be equal to pcselect4
     
     // pass alu, fn & we control signals  randomization to pass through the pipe form decode to issue stage
      alu_fn3 = pkt.alu_fn3_rand; // should be equal to alu_fn4 in simulation
      fn3 = pkt.fn3_rand; // should be equal to fn4
      we3 = pkt.we3_rand; // should be equal to we4
      pc3 = pkt.pc3_rand;  //  should be equal to pc4
      bneq3 = pkt.bneq3_rand ; // should be equal to bneq4
      btype3 = pkt.btype3_rand;// should be equal to btype4
       
      B_SEL3 = pkt. B_SEL3_rand; 
     #10;
   end
  
   end 
endmodule


