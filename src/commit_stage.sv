
module commit_stage(
    input logic clk, nrst,
    input logic [4:0] rd6,
    input logic we6,
    input logic [31:0] U_imm6,AU_imm6,
    input logic [31:0] result6, 
    input logic [31:0] pc6,
    input logic [2:0] fn6,
    input logic [31:0] mem_out6,
    input logic [31:0] mul_div6,


    output logic [4:0] rd6Issue,
    output logic [31:0] wb_data6, // final output that will be written back in register file PIPE #6
    output logic we6Issue
    );

	assign rd6Issue = rd6;
	assign we6Issue = we6;
 	assign wb_data6 = result6;
endmodule
