//this testbench is designed to test registerfile
class packet; // used for randomization of variables
  rand bit [31:0] result_random;
  rand bit [4:0]  write_addr_random;
  rand bit [4:0]  source_a_random;
  rand bit [4:0]  source_b_random;
  
endclass
 
`timescale 1ns/1ns 
module tb_regfile; 
  
reg clk, we, clrn;		            // clk, write enable and negative clear signal to clear register file data
reg [4:0]  write_addr; 	        // destenation address to write back in reg file
reg [4:0]  source_a, source_b;  // address of required operand registers
reg [31:0] result;		            // result that will be written back in register file
wire[31:0] op_a, op_b ; 	      // output of required operands
	
//instantiation of DUTs
regfile DUT (.clk(clk), .we(we), .clrn(clrn),.write_addr(write_addr),.source_a(source_a), .source_b(source_b),.result(result),.op_a(op_a), .op_b(op_b));

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
    
    write_addr=0;
     
	   clrn = 0;
#5  clrn = 1;
     we   = 1;
   repeat(32) begin // to write into the register file
      pkt.randomize();
      write_addr = write_addr+1;
      result     = pkt.result_random;
#10;
    end
// to test that there will be no writes if we = 0
  pkt.randomize();
  we   = 0; 
  write_addr = pkt.write_addr_random;
  result     =pkt.result_random;
#10;
repeat(32) begin // tests that the previously written values are being read correctly
   pkt.randomize();
   source_a = pkt.source_a_random; 
   source_b = pkt.source_b_random;
#10; 
end

     clrn = 0;
#10  clrn = 1;
repeat(32) begin // tests that the reset values are correct
   pkt.randomize();
   source_a = pkt.source_a_random; 
   source_b = pkt.source_b_random; 
#10; 
end
      
   end 
endmodule

