`timescale 10ns / 10ns 
class packet; // used for randomization of variables
  rand bit [31:0] pc_random;
  rand bit [31:0] operandA_random;
  rand bit [31:0] B_imm_random, I_imm_random, J_imm_random;
  rand bit btaken_random, jr_random, j_random; 

constraint btaken_condition { btaken_random == 1 -> jr_random > 0 & j_random > 0 ;}
constraint jr_condition { jr_random == 1 -> btaken_random > 0 & j_random > 0 ;}
constraint j_condition { j_random == 1 -> btaken_random > 0 & jr_random > 0 ;}

endclass

`timescale 1ns/1ns
module tb_branch_unit;
reg  [31:0]  pc; 
reg  [31:0]  operandA;
reg  [31:0]  B_imm, J_imm, I_imm;  
reg  btaken, jr, j;		  
wire [31:0]  target;

// instantiate device under test
 branch_unit dut(.pc(pc), .operandA(operandA), .B_imm(B_imm), .J_imm(J_imm), .I_imm(I_imm), .btaken(btaken), .jr(jr), .j(j), .target(target));

 initial begin
    packet pkt;
    pkt = new();
 repeat(10)begin
 #1   pkt.randomize(); 
      pc        = pkt.pc_random;
      operandA  = pkt.operandA_random;
      B_imm     = pkt.B_imm_random;
      J_imm     = pkt.J_imm_random;
      I_imm     = pkt.I_imm_random;
      jr        = pkt.jr_random;
      j         = pkt.j_random;
      btaken    = pkt.btaken_random; 
end
end
 
endmodule
