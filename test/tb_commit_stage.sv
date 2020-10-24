class packet; // used for randomization of variables
  rand bit [4:0]  rd5_random;
  rand bit [31:0] result5_random; 
 // rand bit [4:0]  rd5_random;
endclass

`timescale 10ns/10ns 
module tb_commit_stage;
reg  clk, nrst;
reg  we5;
reg [4:0]  rd5;
reg [31:0] result5;   // input result from mem to commit stage
reg [31:0] U_imm5;
reg [31:0] pc5;
reg [2:0]  fn5;
reg [31:0] mem_out6;
reg [31:0] mul_div5;

wire [4:0]  rd6;
wire [31:0] U_imm6 ,AU_imm6;
wire [31:0] wb_data6; // final output that will be written back in register file PIPE #6
wire  we6;

// instantiate device under test
  commit_stage dut(.clk(clk), .nrst(nrst), .we5(we5), .rd5(rd5), .U_imm5(U_imm5), .result5(result5), .pc5(pc5), .fn5(fn5), .mem_out6(mem_out6), .mul_div5(mul_div5), .rd6(rd6), .wb_data6(wb_data6),  .U_imm6(U_imm6),  .AU_imm6(AU_imm6), .we6(we6));

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
    nrst = 0; we5 = 0;
    #25  nrst = 1; we5 = 1;
    	repeat(10)begin
     	pkt.randomize(); 
     	rd5     = pkt.rd5_random; 
     	result5 = pkt.result5_random;
	//rd5     = pkt.rd5_random;
end
end
endmodule

