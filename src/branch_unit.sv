

module branch_unit(
	input  logic [31:0]   pc,
	input logic  [31:0]  B_imm,
	input logic btaken,

	output logic [31:0]  b_target
);

assign b_target = btaken ? pc+B_imm : pc+1; // overflow check !
	

endmodule

