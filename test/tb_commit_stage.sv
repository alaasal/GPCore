class packet; // used for randomization of variables
  rand bit [4:0]  rd6_random;
  rand bit [31:0] result6_random; 
  rand bit [31:0] pc6_random;
  rand bit we6_random;
endclass

`timescale 1ns/1ns 
module tb_commit_stage;
reg  clk, nrst;
reg  we6;
reg [4:0]  rd6;
reg [31:0] result6;   // input result from mem to commit stage
reg [31:0] pc6;

wire [31:0] wb_data6;
wire [4:0] rd6Issue; // final output that will be written back in register file PIPE #6
wire  we6Issue;

// instantiate device under test
  commit_stage dut(.clk(clk), .nrst(nrst), .we6(we6), .rd6(rd6),  .result6(result6), .pc6(pc6), .wb_data6(wb_data6), .rd6Issue(rd6Issue), .we6Issue(we6Issue));

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
    nrst = 0; we6 = 0;
    #5  nrst = 1; we6 = 1;
    	repeat(10)begin
     	pkt.randomize(); 
     	rd6     = pkt.rd6_random; 
     	result6 = pkt.result6_random;
	pc6     = pkt.pc6_random;
        we6     = pkt.we6_random;
end
end
endmodule

