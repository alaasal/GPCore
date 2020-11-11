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
	a_rand < 0;
	b_rand < 0;
	mulDiv_op_rand inside {3'b000, 3'b001, 3'b101, 3'b111}; //mul, mulh, div, rem
}

constraint su_con{ //signed unsigned constraint
	a_rand < 0;
	b_rand > 0;
	mulDiv_op_rand inside {3'b010}; //mulhsu
}

endclass

//mulh and mulhsu return false errors
module tb_mul_div ; 
	
		logic signed [31:0] a;
		logic signed [31:0] b;
		logic [2:0] mulDiv_op;

		logic signed [31:0] res;

		string op_type = "mul";

		logic signed [63:0] real_res_reg;
		logic [31:0] real_res;

		bit pass; 
        int mul_count, mulh_count, mulhu_count, mulhsu_count;
        int div_count, divu_count, rem_count, remu_count;
        int mul_failed, mulh_failed, mulhu_failed, mulhsu_failed;
        int div_failed, divu_failed, rem_failed, remu_failed;

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
				
				real_res_reg = (mulDiv_op == 3'b000)? $signed(a) * $signed(b):    //MUL
							(mulDiv_op == 3'b001)? $signed(a) * $signed(b):    //MULH
							(mulDiv_op == 3'b010)? $signed(a) * b:             //MULHSU
							(mulDiv_op == 3'b011)? a * b:                      //MULHU
							(mulDiv_op == 3'b101)? $signed(a) / $signed(b):    //DIV
							(mulDiv_op == 3'b100)? a / b:                      //DIVU
							(mulDiv_op == 3'b111)? $signed(a) % $signed(b):    //REM
							(mulDiv_op == 3'b110)? a % b: 64'hx;               //REMU

				real_res = (mulDiv_op == 3'b000)? real_res_reg[31:0]:
						(mulDiv_op == 3'b001)? real_res_reg[63:32]:
						(mulDiv_op == 3'b010)? real_res_reg[63:32]:
						(mulDiv_op == 3'b011)? real_res_reg[63:32]:
						(mulDiv_op == 3'b101)? real_res_reg[31:0]:
						(mulDiv_op == 3'b100)? real_res_reg[31:0]:
						(mulDiv_op == 3'b111)? real_res_reg[31:0]:
						(mulDiv_op == 3'b110)? real_res_reg[31:0]: 64'hx;
				#1;

				pass = (real_res == res);
				
				case (mulDiv_op)
				    3'b000: begin       //MUL
                        mul_count = mul_count + 1;
                        mul_failed = (pass == 0)? mul_failed + 1: mul_failed; 
					end 3'b001: begin   //mulh
                        mulh_count = mulh_count + 1;
                        mulh_failed = (pass == 0)? mulh_failed + 1: mulh_failed;
					end 3'b010: begin   //mulhsu
                        mulhsu_count = mulhsu_count + 1;
                        mulhsu_failed = (pass == 0)? mulhsu_failed + 1: mulhsu_failed;
					end 3'b011: begin   //mulhu
                        mulhu_count = mulhu_count + 1;
                        mulhu_failed = (pass == 0)? mulhu_failed + 1: mulhu_failed;
					end 3'b101: begin   //div
                        div_count = div_count + 1;
                        div_failed = (pass == 0)? div_failed + 1: div_failed;
					end 3'b100: begin   //divu
                        divu_count = divu_count + 1;
                        divu_failed = (pass == 0)? divu_failed + 1: divu_failed;
					end 3'b111: begin   //rem
                        rem_count = rem_count + 1;
                        rem_failed = (pass == 0)? rem_failed + 1: rem_failed;
					end 3'b110: begin   //remu
                        remu_count = remu_count + 1;
                        remu_failed = (pass == 0)? remu_failed + 1: remu_failed;
					end default: begin
						$display("Invalid Operation");
						break;
					end
				endcase

				$display("| %6s | %8h | %8h | %8h | %8h | %16h | %4d |", op_type, a, b, res, real_res, real_res_reg, pass);
				$display("--------------------------------------------------------------------------------------------------------");
			end

            $display("Simulation finished");
            $display("MUL:    %d, Failed: %d", mul_count, mul_failed);
            $display("MULH:   %d, Failed: %d", mulh_count, mulh_failed);
            $display("MULHU:  %d, Failed: %d", mulhu_count, mulhu_failed);
            $display("MULHSU: %d, Failed: %d", mulhsu_count, mulhsu_failed);
            $display("DIV:    %d, Failed: %d", div_count, div_failed);
            $display("DIVU:   %d, Failed: %d", divu_count, divu_failed);
            $display("REM:    %d, Failed: %d", rem_count, rem_failed);
            $display("REMU:   %d, Failed: %d", remu_count, remu_failed);
		end   
endmodule
