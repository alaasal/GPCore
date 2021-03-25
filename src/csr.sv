module csr_unit(
	input logic [2:0] func3,
	input logic [4:0] rs1,
	input logic [31:0] rs1_val, imm,
	input logic [11:0] csr_addr,
	input logic [31:0] csr_reg,	// csr data that instruction will perform on it
	input logic system,
	// input mode::mode_t  current_mode,
	input logic [1:0] current_mode,
	output logic [31:0] csr_new,	// csr that will be written back in csr regfile
	output logic [31:0] csr_old,	// csr that will be written in rd
	output logic illegal_csr
	);

	always_comb
	  begin
		if(system)
		  begin
		  if (csr_addr[9:8] > current_mode)
		      illegal_csr = 1;
		  else if ((rs1 != 0) && (csr_addr[11:10] == 2'b11))
		      illegal_csr = 1;
		  else
		  begin
			unique case(func3)
				3'b001: csr_new = rs1_val;			// CSRRW		(CSR+Zero Extend) -> RD then rs1 -> CSR
				3'b010: csr_new = csr_reg | rs1_val;	// CSRRS		rs1 mask add
				3'b011: csr_new = csr_reg & (~rs1_val);	// CSRRC		rs1 mask remove
				3'b101: csr_new = imm;			// CSRRWI		the rest is same but with immediate 
				3'b110: csr_new = csr_reg | imm;	// CSRRSI
				3'b111: csr_new = csr_reg & (~imm);	// CSRRCI
				default:csr_new = csr_reg;
			endcase
		  end
		  end
		else
			csr_new = csr_reg;
	  end
	

	assign csr_old = csr_reg;

endmodule
