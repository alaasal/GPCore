//this testbench is designed to test data memory  
//in this test bench we instantiate data_mem
`timescale 1ns/1ns 

class packet; // used for randomization of variables 
parameter XLEN = 32;
rand bit gwe_rand, rd_rand;
rand bit bw0_rand, bw1_rand, bw2_rand, bw3_rand;        
rand bit [XLEN - 1:0] addr_rand, data_in_rand;

constraint my_addr {addr_rand inside {[0:255]};}
endclass

module tb_data_mem ; 
  
  parameter XLEN = 32;
  parameter MEM_LEN  = 256;

reg clk; 
reg gwe, rd;
reg bw0, bw1, bw2, bw3;        
reg [XLEN - 1:0] addr, data_in;

wire [XLEN - 1: 0] data_out; 
	
//instantiation of DUTs
data_mem #(
    .XLEN        (XLEN),
    .MEM_LEN     (MEM_LEN)
    )  dut (.clk(clk),.gwe(gwe), .rd(rd),.bw0(bw0), .bw1(bw1), .bw2(bw2), .bw3(bw3),.addr(addr), .data_in(data_in),.data_out(data_out));
//clocks  generation
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
   
        clk     <= 0;
        gwe     <= 0;
        rd      <= 0;
        addr    <= 0;
        data_in <= 0;
        
        #10;

   repeat (10) begin
     pkt.randomize();
     gwe     =   1;
     rd      =   0;
     bw0     =   0;
     bw1     =   0;
     bw2     =   0;
     bw3     =   0;
     addr    =   addr +4;
     data_in =   pkt.data_in_rand;
     #10;
   end
    repeat (5) begin
     pkt.randomize();
     gwe     =   0;
     rd      =   0;
     bw0     =   1;
     bw1     =   0;
     bw2     =   0;
     bw3     =   0;
     addr    =   addr +4;//pkt.addr_rand;
     data_in =   pkt.data_in_rand;
     #10;
   end
   repeat (5) begin
     pkt.randomize();
     gwe     =   0;
     rd      =   0;
     bw0     =   0;
     bw1     =   1;
     bw2     =   0;
     bw3     =   0;
     addr    =   addr +4;//pkt.addr_rand;
     data_in =   pkt.data_in_rand;
     #10;
   end
   repeat (5) begin
     pkt.randomize();
     gwe     =   0;
     rd      =   0;
     bw0     =   0;
     bw1     =   0;
     bw2     =   1;
     bw3     =   0;
     addr    =   addr +4;//pkt.addr_rand;
     data_in =   pkt.data_in_rand;
     #10;
   end
   repeat (5) begin
     pkt.randomize();
     gwe     =   0;
     rd      =   0;
     bw0     =   0;
     bw1     =   0;
     bw2     =   0;
     bw3     =   1;
     addr    =   addr +4;
     data_in =   pkt.data_in_rand;
     #10;
   end
    addr    <= 0;
    #10;
    repeat (30) begin
     pkt.randomize();
     gwe     =   pkt.gwe_rand;
     rd      =   1;
     bw0     =   pkt.bw0_rand;
     bw1     =   pkt.bw1_rand;
     bw2     =   pkt.bw2_rand;
     bw3     =   pkt.bw3_rand;
     addr    =   addr +4;
     data_in =   pkt.data_in_rand;
     #10;
   end
   
     repeat (50) begin //randomizing all
     pkt.randomize();
     gwe     =   pkt.gwe_rand;
     rd      =   pkt.rd_rand;
     bw0     =   pkt.bw0_rand;
     bw1     =   pkt.bw1_rand;
     bw2     =   pkt.bw2_rand;
     bw3     =   pkt.bw3_rand;
     addr    =   pkt.addr_rand;
     data_in =   pkt.data_in_rand;
     #10;
   end
     
     
   
 end
   
endmodule


