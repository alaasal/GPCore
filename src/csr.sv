// CSR Instructions //
`define csrw  3'b001
`define csrs  3'b010
`define csrc  3'b011
`define csrwi 3'b101
`define csrsi 3'b110
`define csrci 3'b111

module csr_unit(
	input logic [2:0] func3,
	input logic [4:0] rs1,
	input logic [31:0] rs1_val, imm,
	input logic [11:0] csr_addr,
	input logic [31:0] csr_reg,	// csr data that instruction will perform on it
	input logic system,
	input logic [1:0] current_mode,
	output logic [31:0] csr_new,	// csr that will be written back in csr regfile
	output logic [31:0] csr_old,	// csr that will be written in rd
	output logic illegal_csr
	);

	always_comb
	  begin
		if(system)
		  begin
		  /************************************************************************************************  
		      Attempts to access a CSR without appropriate privilege level or to write a read-only register
		      raise illegal instruction exceptions.
		  ************************************************************************************************/
		  if (csr_addr[9:8] > current_mode)
		     illegal_csr = 1;
		  else if ((rs1 != 0) && (csr_addr[11:10] == 2'b11) && ((func3 == `csrw) || func3 == `csrwi))
		      illegal_csr = 1;
		  else
		  begin
		    illegal_csr = 0;
			unique case(func3)
				`csrw: csr_new = rs1_val;
				`csrs: csr_new = csr_reg | rs1_val;
				`csrc: csr_new = csr_reg & (~rs1_val);
				`csrwi: csr_new = imm; 
				`csrsi: csr_new = csr_reg | imm;
				`csrci: csr_new = csr_reg & (~imm);
				default:csr_new = csr_reg;
			endcase
		  end
		  end
		else
			csr_new = csr_reg;
	  end
	

	assign csr_old = csr_reg; // to rd

endmodule
