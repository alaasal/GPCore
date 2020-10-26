module csr(
	input logic [2:0] func3,
	input logic [31:0] rs1, imm,
	input logic [31:0] csr_reg,
	output logic [31:0] csr_new,	// csr that will be written back in csr regfile
	output logic [31:0] csr_old	// csr that will be written in rd 
	);

	always_comb
	  begin
		unique case(func3)
			3'b001: csr_new = rs1;			// CSRRW
			3'b010: csr_new = csr_reg | rs1;	// CSRRS
			3'b011: csr_new = csr_reg & (~rs1);	// CSRRC
			3'b101: csr_new = imm;			// CSRRWI
			3'b110: csr_new = csr_reg | imm;	// CSRRSI
			3'b111: csr_new = csr_reg & (~imm);	// CSRRCI
			default:csr_new = csr_reg;
		endcase
	  end

	assign csr_old = csr_reg;

endmodule
