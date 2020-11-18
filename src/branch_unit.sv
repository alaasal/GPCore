module branch_unit(
	input  logic [31:0]   pc,
	input logic [31:0] operandA,
	input logic  [31:0]  B_imm, J_imm, I_imm,
	input logic btaken, jr, j,

	output logic [31:0]  target
);

//TODO: add instruction-address-misaligned exception support

logic [31:0] b_target, j_target;


assign b_target = btaken ? pc+B_imm : pc+1; // overflow check!
assign j_target = (jr)? operandA + I_imm : pc + J_imm;


always_comb begin
	if (j) target = j_target;
	else if (jr) target = {j_target[31:1], 1'b0};
	else target = b_target;
end

endmodule
