
 `timescale 10ns / 10ns 
 
class packet;
rand bit [31:0] operandA_rand;
rand bit [31:0] operandB_rand;
rand bit [3:0]   alu_fn_rand;
rand bit bneq_rand,btype_rand;
endclass


module tb_alu;

	reg bneq,btype;
	reg [3:0]   alu_fn;
	reg [31:0]  operandA;
	reg [31:0]  operandB;
	
	wire btaken;
	wire [31:0]  result;


 
 // DUT instantiation
 alu DUT(.bneq(bneq),.btype(btype),.alu_fn(alu_fn),.operandA(operandA),.operandB(operandB),.btaken(btaken),.result(result));
    initial begin
     packet pkt;
     pkt = new(); 
     
     repeat(5)begin
#1   pkt.randomize();
     operandA = pkt.operandA_rand;
     operandB = pkt.operandB_rand;
     alu_fn   = pkt.alu_fn_rand;
     bneq     = pkt.bneq_rand;
     btype    = pkt.btype_rand;
    
   end
      
    end   
endmodule
