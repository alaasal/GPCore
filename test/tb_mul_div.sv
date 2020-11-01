`timescale 1ns/1ns 

class packet; // used for randomization of variables 
rand logic signed [31:0] a_rand;
rand logic signed [31:0] b_rand;
rand logic [2:0] mulDiv_op_rand;
endclass

module tb_mul_div ; 
  
    logic signed [31:0] a;
    logic signed [31:0] b;
    logic [2:0] mulDiv_op;

    logic [31:0] res;

    string op_type = "mul";

    //instantiation of DUTs
    mul_div dut(.a(a),.b(b),.mulDiv_op(mulDiv_op),.res(res));

    //stimulus generation 
    initial begin 
      logic signed [63:0] real_res_reg;
      logic [31:0] real_res;
      packet pkt;
      pkt = new(); 
      $display("-----------------TESTING (Signed A, Signed B)-----------------");

      repeat (30)begin
        pkt.randomize();
        a         = pkt.a_rand;
        b         = pkt.b_rand;
        mulDiv_op = 2'b00;

        // 000 -> mul 	
	      // 001 -> mulh
	      // 010 -> mulhsu
	      // 011 -> mulhu
	      // 101 -> div 
	      // 100 -> divu
	      // 111 -> rem
	      // 111 -> remu

        op_type = (mulDiv_op == 3'b000)? "MUL":
                  (mulDiv_op == 3'b001)? "MULH":
                  (mulDiv_op == 3'b010)? "MULHSU":
                  (mulDiv_op == 3'b011)? "MULHU":
                  (mulDiv_op == 3'b101)? "DIV":
                  (mulDiv_op == 3'b100)? "DIVU":
                  (mulDiv_op == 3'b111)? "REM":
                  (mulDiv_op == 3'b110)? "REMU": "INVAL";

        real_res_reg = $signed(a) * $signed(b);
        real_res = real_res_reg[31:0];  

        
  
        #1;
        $display("\top_type = %s \tA = %d \tB = %d \ttb_res = %d \treal_res = %d \tfull_res = %d", op_type, a, b, res, real_res, real_res_reg);
      end
    end   
endmodule



