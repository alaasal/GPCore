`timescale 1ns/1ns 

class packet; // used for randomization of variables 
rand bit [3:0]  mem_op4_rand;          
rand bit [31:0] op_a4_rand;        
rand bit [31:0] op_b4_rand;        
rand bit [31:0] S_imm4_rand;  

 constraint my_mem_op { mem_op4_rand inside {4'b 0001, 4'b0010,4'b0011,4'b0100,4'b0101};}
 constraint my_addr {op_a4_rand+S_imm4_rand inside {[0:255]};}     

endclass

module tb_mem_wrap ; 
  
 reg clk, nrst;
 reg [3:0]  mem_op4;          
 reg [31:0] op_a4;        
 reg [31:0] op_b4;        
 reg [31:0] S_imm4;       

 wire [31: 0] mem_out6;
 wire addr_misaligned6;
	
//instantiation of DUTs
mem_wrap dut(.clk(clk), .nrst(nrst),.mem_op4(mem_op4),.op_a4(op_a4),.op_b4(op_b4),.S_imm4(S_imm4),.mem_out6(mem_out6),.addr_misaligned6(addr_misaligned6));
 
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
     op_a4   = 0;          
     S_imm4  = 0;  
#5  nrst = 1;
 repeat (30)begin
   
     pkt.randomize(); 
     mem_op4 = pkt.mem_op4_rand;        
     op_a4   = op_a4+2;   
     op_b4   = pkt.op_b4_rand;        
     S_imm4  = S_imm4+2;     

     #10;
   
 end
     op_a4   = 0;          
     S_imm4  = 0;     
     #10;
 repeat (30)begin
     pkt.randomize();
     mem_op4 = pkt.mem_op4_rand; 
     op_a4   = op_a4+2;           
     S_imm4  = S_imm4+2;         
     #10;
   
 end
 
 repeat (30)begin
     pkt.randomize();
     mem_op4 = pkt.mem_op4_rand; 
     op_a4   = pkt.op_a4_rand;           
     S_imm4  = pkt.S_imm4_rand;          
     #10;
   
 end
 
   end 
   
endmodule


