
 `timescale 1ns / 1ns 
//run for 6 microseconds
typedef enum bit[3:0] {ADD = 0, SUB = 8,
    SLL = 1, SRL = 5, SRA = 13, 
    XOR = 4, OR = 6, AND = 7,
    BGE = 9, BGEU = 10, SLT = 2, SLTU = 3} opcode;

class packet;
rand bit [31:0] operandA_rand;
rand bit [31:0] operandB_rand;
rand opcode   alu_fn_rand;
rand bit bneq_rand,btype_rand;
endclass

module alu_gold(
	input  logic bneq,btype,
	input  logic [3:0]   alu_fn,
	input  logic signed [31:0]  operandA,
	input  logic signed [31:0]  operandB,

	output logic btaken,
	output logic signed [31:0]  result
);
	always_comb begin
		unique case(alu_fn)
			4'b0000: result = $signed(operandA) + $signed(operandB);
			4'b0001: result = $signed(operandA) << $signed(operandB);
			4'b0010: result = ($signed(operandA) < $signed(operandB));
			4'b0011: result = ($unsigned(operandA) < $unsigned(operandB)); 
			4'b0100: result = $signed(operandA) ^ $signed(operandB);
			4'b0101: result = $signed(operandA) >> $signed(operandB);
			4'b0110: result = $signed(operandA) | $signed(operandB);
			4'b0111: result = $signed(operandA) & $signed(operandB);
			4'b1000: result = $signed(operandA) - $signed(operandB);
			4'b1001: result = ($signed(operandA) > $signed(operandB));  // for bge 
			4'b1010: result = ($unsigned(operandA) > $unsigned(operandB));  		    // for bgeu
			4'b1011: result = 0;
			4'b1100: result = 0;
			4'b1101: result = $signed(operandA) >>> $signed(operandB);
			
			default: result = 0;
		endcase 
        
        if (btype) begin 
			unique case(alu_fn)
				4'b1000: begin 
					if(bneq)  btaken =  |result ? 1'b1 : 1'b0 ; // result not equal 0 bne 
					else      btaken = ~|result ? 1'b1 : 1'b0 ; // result equal 0 beq 
				end 
				4'b0010: 	  btaken =  |result ? 1'b1 : 1'b0 ; // blt
				4'b0011: 	  btaken =  |result ? 1'b1 : 1'b0 ; // bltu
				4'b1001: 	  btaken =  |result ? 1'b1 : 1'b0 ; // bge
				4'b1010: 	  btaken =  |result ? 1'b1 : 1'b0 ; // bgeu

				default:  btaken = 0;
			endcase
		end  else btaken =0;
	end
endmodule

module tb_alu;

	logic bneq,btype;
	opcode   alu_fn;
	logic [31:0]  operandA;
	logic [31:0]  operandB;
	
	logic btaken, btaken_gold;
	logic [31:0]  result, result_gold;

 alu_gold alu_gold (
    .bneq        (bneq),
    .btype       (btype),
    .alu_fn      (alu_fn),
    .operandA    (operandA),
    .operandB    (operandB),
    .btaken      (btaken_gold),
    .result      (result_gold)
);

 // DUT instantiation
 alu DUT(.bneq(bneq),.btype(btype),.alu_fn(alu_fn),.operandA(operandA),.operandB(operandB),.btaken(btaken),.result(result));
    initial begin
     packet pkt;
     pkt = new(); 
     
     repeat(1000) begin
#5   if(!pkt.randomize()) $error;
     operandA = pkt.operandA_rand;
     operandB = pkt.operandB_rand;
     alu_fn   = pkt.alu_fn_rand;
     bneq     = pkt.bneq_rand;
     btype    = pkt.btype_rand;
    #1
    assert(result_gold == result) 
        else $error("alu function fail: alu_fun = %s, A = %10h, B = %10h, result = %10h, expected = %10h", alu_fn.name(), operandA, operandB, result, result_gold);
    if (btype) begin
        assert(btaken_gold == btaken) 
            else $warning("branch fail: btype = %2d, bneq = %2d, alu_fun = %s, A = %10h, B = %10h", btype, bneq, alu_fn.name(), operandA, operandB);
    end 
    end
    $display("Simulation successful");
    $stop;
    end   
endmodule
