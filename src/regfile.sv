module regfile (
	input  logic clk, we, clrn,		  // clk, write enable and negative clear signal to clear register file data
	input  logic [4:0]  write_addr, 	  // destenation address to write back in reg file
	input  logic [4:0]  source_a, source_b, // address of required operand registers
	input  logic [31:0] result,		  // result that will be written back in register file
	output logic [31:0] op_a, op_b  	  // output of required operands
	);

	logic [31:0] register [31:0]; // 31 32-bit registers (x0 is excluded)


	always_ff @(posedge clk or negedge clrn)
	  begin
		if (!clrn)
		  begin	// iterate on reg array indices to clear registers
		  	register[0] <= 32'h0;
			for (int i = 1; i < 32; i = i + 1)
				register[i] <= 32'h0;      // clear register file
		  end
		else
		  begin
			op_a = register[source_a];
			op_b = register[source_b];
			if ((write_addr != 0) && we)  // make sure not write in x0
				register[write_addr] <= result;
		  end
	  end

endmodule
