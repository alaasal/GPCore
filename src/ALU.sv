module alu(
    input  logic [3:0]   alu_fn,
    input  logic [31:0]  operandA,
    input  logic [31:0]  operandB,

    output logic [31:0]  result
);

	always_comb
	  begin
		// npc logic
		unique case(alu_fn)
			0: result = operandA + operandB;
			1: result = 0;
			2: result = 0;
			3: result = 0;
			4: result = 0;
			5: result = 0;
			6: result = 0;
			7: result = 0;
			8: result = operandA - operandB;
			9: result = 0;
			10: result = 0;
			11: result = 0;
			12: result = 0;
			13: result = 0;
			14: result = 0;
			15: result = 0;
			16: result = 0;
			17: result = 0;
			18: result = 0;
			19: result = 0;
			20: result = 0;
			21: result = 0;
			22: result = 0;
			23: result = 0;
			24: result = 0;
			25: result = 0;
			26: result = 0;
			27: result = 0;
			28: result = 0;
			29: result = 0;
			30: result = 0;
			31: result = 0;
			default: result = 0;
		endcase
	  end

endmodule


