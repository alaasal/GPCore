module csr(
	input logic [2:0] func3,
	input logic [31:0] rs1, imm,
	input logic [31:0] csr_reg,	// csr data that instruction will perform on it
	input logic system,
	input mode::mode_t  current_mode,
	output logic [31:0] csr_new,	// csr that will be written back in csr regfile
	output logic [31:0] csr_old	// csr that will be written in rd
	);

	always_comb
	  begin
		if(system)
		  begin
			unique case(func3)
				3'b001: csr_new = rs1;			// CSRRW		(CSR+Zero Extend) -> RD then rs1 -> CSR
				3'b010: csr_new = csr_reg | rs1;	// CSRRS		rs1 mask add
				3'b011: csr_new = csr_reg & (~rs1);	// CSRRC		rs1 mask remove
				3'b101: csr_new = imm;			// CSRRWI		the rest is same but with immediate 
				3'b110: csr_new = csr_reg | imm;	// CSRRSI
				3'b111: csr_new = csr_reg & (~imm);	// CSRRCI
				default:csr_new = csr_reg;
			endcase
		  end
		else
			csr_new = csr_reg;
	  end
	

	assign csr_old = csr_reg;

endmodule
