
module commit_stage(
	input logic clk, 
	input logic nrst,

	input logic [31:0] result6,
	input logic [4:0] rd6,
	input logic we6, 

	input logic [31:0] pc6,

	output logic [31:0] wb_data6,
	output logic [4:0] rd6Issue,
	output logic we6Issue
    );

	assign rd6Issue = rd6;
	assign we6Issue = we6;
 	assign wb_data6 = result6;
endmodule
