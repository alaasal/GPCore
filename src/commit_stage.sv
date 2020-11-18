
module commit_stage(
	input logic clk, 
	input logic nrst,

	input logic [31:0] result6,
	input logic [4:0] rd6,
	input logic we6,
	input logic [31:0] pc6,
	// csr & exceptions
	input logic [31:0] csr_wb6,
	input logic [11:0] csr_wb_addr6,
	input logic csr_we6,
	input logic [31:0] cause6,
	input logic exception_pending6,
	input logic mret6, sret6, uret6,

	output logic [31:0] wb_data6,
	output logic [4:0] rd6Issue,
	output logic we6Issue,

	output logic [31:0] csr_wb,
	output logic [11:0] csr_wb_addr,
	output logic csr_we6Issue,
	output logic [31:0] pc_exc,
	output logic [31:0] cause,
	output logic exception_pending,
	output logic mret, sret, uret
    );
	
	assign rd6Issue = rd6;
	assign we6Issue = we6;
 	assign wb_data6 = result6;

	assign csr_wb = csr_wb6;
	assign csr_wb_addr = csr_wb_addr6;
	assign csr_we6Issue = csr_we6;
	assign pc_exc = pc6;
	assign cause = cause6;
	assign exception_pending = exception_pending6;
	assign mret	= mret6;
	assign sret	= sret6;
	assign uret	= uret6;
endmodule
