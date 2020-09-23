module regfile (
	input clk, we, clrn,		  // clk, write enable and negative clear signal to clear register file data
	input  [4:0]  write_addr, 	  // destenation address to write back in reg file
	input  [4:0]  source_a, source_b, // address of required operand registers
	input  [31:0] result,		  // result that will be written back in register file
	output [31:0] op_a, op_b  	  // output of required operands
	);

	logic [31:0] register [1:31]; 	  // 31 32-bit registers (x0 is excluded)

	// register x0 is hardwired with all bits equal to 0
	assign op_a = (source_a == 0) ? 0 : register[source_a];
	assign op_b = (source_b == 0) ? 0 : register[source_b];

	always_ff @(posedge clk, negedge clrn)
	  begin
		if (!clrn)
		  begin	// iterate on reg array indices to clear registers
			for (int i = 1; i < 32; i = i + 1)
				register[i] <= 0;      // clear register file
		  end
		else
		  begin
			if ((write_addr != 0) && we)  // make sure not write in x0
				register[write_addr] <= result;
		  end
	  end

endmodule
