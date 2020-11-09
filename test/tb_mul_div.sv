`timescale 1ns/1ns 

class packet; // used for randomization of variables 
rand logic signed [31:0] a_rand;
rand logic signed [31:0] b_rand;
rand logic [2:0] mulDiv_op_rand; 

constraint u_con{ //unsigned constraint
  a_rand > 0;
  b_rand > 0;
  mulDiv_op_rand inside {3'b011, 3'b100, 3'b110}; //mulhu, divu, remu
}

constraint s_con{ //signed constraint
  mulDiv_op_rand inside {3'b000, 3'b001, 3'b101, 3'b111}; //mul, mulh, div, rem
}

constraint su_con{ //signed unsigned constraint
  a_rand > 0;
  mulDiv_op_rand inside {3'b010}; //mulhsu
}

endclass

module tb_mul_div ; 
  
    logic signed [31:0] a;
    logic signed [31:0] b;
    logic [2:0] mulDiv_op;

    logic [31:0] res;

    string op_type = "mul";

    logic signed [63:0] real_res_reg;
    logic [31:0] real_res;
    packet pkt;

    //instantiation of DUTs
    mul_div dut(.a(a),.b(b),.mulDiv_op(mulDiv_op),.res(res));

    //stimulus generation 
    initial begin 
      pkt = new(); 
      $display("-------------------------------------------------TESTING------------------------------------------------");
      $display("| %6s | %13s | %13s | %13s | %13s | %20s | %4s |", "OpCode", "A", "B", "DUT", "Real Result", "Full Result", "Pass");
      $display("--------------------------------------------------------------------------------------------------------");

      for (int i = 0; i < 3000; i++)begin
        
        pkt.constraint_mode(0); //disable all constraints
        if (i < 1000) pkt.u_con.constraint_mode(1);
        else if (i < 2000) pkt.s_con.constraint_mode(1);
        else pkt.su_con.constraint_mode(1);

        pkt.randomize();
        a         = pkt.a_rand;
        b         = pkt.b_rand;
        mulDiv_op = pkt.mulDiv_op_rand;

        // 000 -> mul 	
	      // 001 -> mulh
	      // 010 -> mulhsu
	      // 011 -> mulhu
	      // 101 -> div 
	      // 100 -> divu
	      // 111 -> rem
	      // 110 -> remu

        //the following three assignements are really, really stupid. will change in future but not now, feeling lazy.
        op_type = (mulDiv_op == 3'b000)? "MUL":
                  (mulDiv_op == 3'b001)? "MULH":
                  (mulDiv_op == 3'b010)? "MULHSU":
                  (mulDiv_op == 3'b011)? "MULHU":
                  (mulDiv_op == 3'b101)? "DIV":
                  (mulDiv_op == 3'b100)? "DIVU":
                  (mulDiv_op == 3'b111)? "REM":
                  (mulDiv_op == 3'b110)? "REMU": "INVAL";
        
        real_res_reg = (mulDiv_op == 3'b000)? a * b:
                       (mulDiv_op == 3'b001)? a * b:
                       (mulDiv_op == 3'b010)? a * b:
                       (mulDiv_op == 3'b011)? a * b:
                       (mulDiv_op == 3'b101)? a / b:
                       (mulDiv_op == 3'b100)? a / b:
                       (mulDiv_op == 3'b111)? a % b:
                       (mulDiv_op == 3'b110)? a % b: 64'hx;

        real_res = (mulDiv_op == 3'b000)? real_res_reg[31:0]:
                   (mulDiv_op == 3'b001)? real_res_reg[63:32]:
                   (mulDiv_op == 3'b010)? real_res_reg[63:32]:
                   (mulDiv_op == 3'b011)? real_res_reg[63:32]:
                   (mulDiv_op == 3'b101)? real_res_reg[31:0]:
                   (mulDiv_op == 3'b100)? real_res_reg[31:0]:
                   (mulDiv_op == 3'b111)? real_res_reg[31:0]:
                   (mulDiv_op == 3'b110)? real_res_reg[31:0]: 64'hx;
        #1;
        //$display("\top_type = %5s\t \tA = %d \tB = %d \tDUT_res = %d \treal_res = %d \tfull_res = %d \tpass = %d ", op_type, a, b, res, real_res, real_res_reg, real_res == res);
        $display("| %6s | %13h | %13h | %13h | %13h | %20h | %4d |", op_type, a, b, res, real_res, real_res_reg, real_res == res);
        $display("--------------------------------------------------------------------------------------------------------");
      end
    end   
endmodule



