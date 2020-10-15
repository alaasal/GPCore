
class packet; // used for randomization of variables
	rand bit  we4_rand ,bneq4_rand ,btype4_rand;
	rand bit [2:0]fn4_rand;
	rand bit [4:0] rd4_rand;
	rand bit  [3:0] alu_fn4_rand;
	rand bit [31:0] op_a_rand, op_b_rand;
	rand bit [31:0] pc4_rand,B_imm4_rand, J_imm4_rand;
	rand bit [1:0] pcselect4_rand;
	rand bit j4_rand, jr4_rand;  
endclass

module tb_exe_stage;
reg clk, nrst; 
reg   we4 ,bneq4 ,btype4;
reg [2:0] fn4;
reg [4:0] rd4;
reg  [3:0] alu_fn4;
reg  [31:0] op_a, op_b;
reg [31:0] pc4,B_imm4, J_imm4;
reg [1:0] pcselect4;
reg j4, jr4;

wire  we5;
wire [2:0] fn5;
wire [31:0] alu_res5;
wire [4:0] rd5;
wire [31:0] target;
wire [1:0] pcselect5;
wire j5, jr5;

// instantiate device under test
 exe_stage dut(.clk(clk), .nrst(nrst), .fn4(fn4), .we4(we4), .bneq4(bneq4), .btype4(btype4), .rd4(rd4), .alu_fn4(alu_fn4), .op_a(op_a), .op_b(op_b), .pc4(pc4) , .B_imm4(B_imm4) ,  .J_imm4(J_imm4), .pcselect4(pcselet4) , .j4(j4), .jr4(jr4), .fn5(fn5) , .we5(we5) , .alu_res5(alu_res5) , .rd5(rd5) , .b_target(b_target) , .pcselect5(pcselect5) , .j5(j5), .jr5(jr5) );

// generate clock
initial begin 
    clk =0; 
 end 
 always
 #10 clk = ~clk;

//stimulus generation 
 initial begin
    packet pkt;
    pkt = new(); 
     
     nrst = 0;
     #25  nrst = 1;
    
     repeat(10)begin
     pkt.randomize();

	fn4 = pkt.fn4_rand;
	we4 = pkt.we4_rand;
	bneq4 = pkt.bneq4_rand ;
	btype4 = pkt.btype4_rand ;
	rd4 =  pkt.rd4_rand ;
	alu_fn4 = pkt.alu_fn4_rand ;
	op_a =  pkt.op_a_rand ;
	op_b =  pkt.op_b_rand ;
	pc4 =  pkt.pc4_rand ;
	B_imm4 =  pkt.B_imm4_rand  ;
	J_imm4 = pkt.J_imm4_rand;
	pcselect4 =  pkt.pcselect4_rand ;
	j4 =  pkt.j4_rand  ;
	jr4 =  pkt.jr4_rand  ;
     
   
  end
   end 
endmodule

