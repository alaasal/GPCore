//this testbench is designed to test issue stage
class packet; // used for randomization of variables
  rand bit [4:0] rdaddr6_rand;
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
  
  rand bit [31:0] pc3_rand;
  rand bit [1:0] pcselect3_rand;
  
endclass
 
`timescale 10ns/10ns 
module tb_issue; 
  
reg clk, nrst;
reg we6;			// we from commit stage pipe #6
reg we3, fn3 , bneq3,btype3;	// we enable for regfile & fn for result selection (from pipe #3)
reg [4:0] rdaddr6;		// destenation address from commit stage to regfile
reg [1:0] B_SEL3; 		// B_SEL for op_b or I_immediates
reg [3:0] alu_fn3;		// alu control from decode stage
reg [31:0] wb6;			// data to be written in regfile
reg [4:0] rs1, rs2;		// addresses of operands (to regfile)	
reg [4:0] rd3;			// rd address will be pipelined to commit stage
reg [4:0] shamt;		
reg [31:0] I_imm3,B_imm3;	// I_immediate sign extended
reg [31:0] pc3;
reg [1:0] pcselect3;

wire fn4, we4,bneq4,btype4;	// function selection ctrl in issue stage and write enable
wire [1:0] pcselect4;
wire [31:0] op_a, op_b;		// operands A & B output from regfile in PIPE #4 (to exe stage)
wire [4:0] rd4;
wire [3:0] alu_fn4;		// alu control in issue stage
wire [31:0] pc4,B_imm4;
	
//instantiation of DUT
 issue_stage DUT(.clk(clk), .nrst(nrst),.we6(we6),.we3(we3), .fn3(fn3) ,.bneq3(bneq3),.btype3(btype3),.rdaddr6(rdaddr6),.B_SEL3(B_SEL3),
 .alu_fn3(alu_fn3),.wb6(wb6),.rs1(rs1),.rs2(rs2),.rd3(rd3),.shamt(shamt),.I_imm3(I_imm3),.B_imm3(B_imm3),.pc3(pc3),.pcselect3(pcselect3),
 .fn4(fn4), .we4(we4),.bneq4(bneq4),.btype4(btype4),.pcselect4(pcselect4),.op_a(op_a),.op_b(op_b),.rd4(rd4),.alu_fn4(alu_fn4), .pc4(pc4),.B_imm4(B_imm4));

//clock  generation
initial begin 
    clk = 0; 
 end 
 always begin 
 #10 clk = ~clk;
  end
  

//stimulus generation 
 initial begin
    packet pkt;
    pkt = new(); 
     
	   nrst = 0;
#25  nrst = 1;
     we6  = 1;
  repeat(10)begin
     pkt.randomize();
    
     rdaddr6 = pkt.rdaddr6_rand; // destenation address from commit stage to regfile 
     wb6 = pkt.wb6_rand;         // randomizing data written into regfile from commit stage
     rs1 = pkt.rs1_rand;
     rs2 = pkt.rs2_rand;
     
     // randomizing signals that are piped from pipe3 to pipe4
     rd3 = pkt.rd3_rand;         // should be equal to rd4
     shamt = pkt.shamt_rand;    // should be equal to shmatreg4
     I_imm3 = pkt.I_imm3_rand; // to be muxed with operand B
     B_imm3 = pkt.B_imm3_rand; // should be equal to B_imm4 
     pcselect3 = pkt.pcselect3_rand; // should be equal to pcselect4
     
     // pass alu, fn & we control signals  randomization to pass through the pipe form decode to issue stage
      alu_fn3 = pkt.alu_fn3_rand; // should be equal to alu_fn4 in simulation
      fn3 = pkt.fn3_rand; // should be equal to fn4
      we3 = pkt.we3_rand; // should be equal to we4
      pc3 = pkt.pc3_rand;  //  should be equal to pc4
      bneq3 = pkt.bneq3_rand ; // should be equal to bneq4
      btype3 = pkt.btype3_rand;// should be equal to btype4
       
     B_SEL3 = 2'b00; 
     repeat(3)begin
      #25 B_SEL3 = B_SEL3+1;
       
     end
  end
   end 
endmodule


