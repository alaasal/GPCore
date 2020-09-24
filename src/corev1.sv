module core(
		input logic clk, nrst,
		// these outputs to observe the data flow in pipelines
		output logic [31:0] pc,      	// program counter PIPE #1
		output logic [31:0] pc_mem,   	// pc at instruction mem pipe #2
		output logic [31:0] inst,    	// instruction in PIPE #3
	 	output logic [31:0] alu_result  // alu result in PIPE #4
	);

	// control signals
	logic pcsel, B_SEL, we;    // pc selection / operand B selection / reg file write enable

	// *hardwired comtrol signal for testing untill implementing our control logic* //
	assign pcsel = 0;          // to increment pc by 4
	assign B_SEL = 1; 	   // to choose sign extended immediate
	assign we = 0;		   // to not write back in regfile

	// wires
	logic [31:0] ins;   	   // output wire of IF stage
	logic [31:0] op_a, op_b;   // operands value output from issue stage
	
	// instantiating stages (4 pipelines)
	IF_stage s1 (.clk(clk), .nrst(nrst), .PCSEL(pcsel), .pc(pc), .pc_mem(pc_mem), .inst(ins));
	issue_stage s2 (.clk(clk), .nrst(nrst), .we(we), .B_SEL(B_SEL), .inst(ins), .op_a(op_a), .op_b(op_b));
	exe_stage s3 (.clk(clk), .nrst(nrst), .op_a(op_a), .op_b(op_b), .alu_res(alu_result));
	
	// output
	assign inst = ins;

endmodule
