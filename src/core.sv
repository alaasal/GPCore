module core(
	input logic clk, nrst,

	input logic DEBUG_SIG,				//DEBUG Signals from debug module to load a program
	input logic [31:0] DEBUG_addr,
	input logic [31:0] DEBUG_instr,
	input logic clk_debug
	);

	// wires
	logic [31:0] pc,pc2,pc3,pc4;         // wires conneting pc to exe  
	logic [31:0] instr2;   	   // output wire of IF stage
	logic [31:0] opa, opb;     // operands value output from issue stage
	logic [4:0] rs1, rs2;
	logic [31:0] I_imm3,B_imm3;
	logic [31:0] B_imm4;
	logic btype3,btype4,bneq3,bneq4;
	logic [31:0] b_target;
	logic [4:0] rd3, rd4, rd5, rd6;  //(rd3 connect between output of pipe #3 and and input of pipe #4)
	logic [4:0] shamt;
	//logic we3, we4, we5, we6;
	//logic fn3, fn4, fn5;
	logic [1:0] pcselect3,pcselect4,pcselect5;	// pcselect output from pipe 3 to pipe 1
	logic [1:0] B_SEL3;
	logic [3:0] alu_fn3, alu_fn4;
	logic [31:0] alu_result5;   // alu result output from exe to commit
	logic [31:0] wb6;	   // data output from commit stage to regfile to be written
	
	// instantiating stages (7 pipelines)
	frontend_stage frontend (
	.clk(clk),
	.nrst(nrst),
	.PCSEL(pcselect5),
	.pc(pc),
	.pc2(pc2),
	.instr2(instr2),
	.DEBUG_SIG(DEBUG_SIG),				//DEBUG Signals from debug module to load a program
	.DEBUG_addr(DEBUG_addr),
	.DEBUG_instr(DEBUG_instr),
	.clk_debug(clk_debug),
	.b_target(b_target)); 

		instdec_stage instdec (.clk(clk), .nrst(nrst), .instr2(instr2), .rs1(rs1), .rs2(rs2), .rd3(rd3), .shamt(shamt), .I_imm3(I_imm3),
				.we3(we3), .pcselect3(pcselect3), .fn3(fn3), .B_SEL3(B_SEL3), .alu_fn3(alu_fn3) , .pc2(pc2) ,.pc3(pc3) ,
					 .bneq3(bneq3) , .btype3(btype3) , .B_imm3(B_imm3) );

	issue_stage issue (.clk(clk), .nrst(nrst), .we6(we6), .we3(we3), .fn3(fn3), .rdaddr6(rd6), .B_SEL3(B_SEL3), .alu_fn3(alu_fn3),
			 .wb6(wb6), .rs1(rs1), .rs2(rs2), .rd3(rd3), .shamt(shamt), .I_imm3(I_imm3),.B_imm3(B_imm3), .op_a(opa), .op_b(opb),
			 .alu_fn4(alu_fn4), .rd4(rd4), .fn4(fn4), .we4(we4) , .pc3(pc3) , .pc4(pc4) ,.B_imm4(B_imm4) , .bneq3(bneq3) , .btype3(btype3) ,
				.bneq4(bneq4) , .btype4(btype4),.pcselect3(pcselect3), .pcselect4(pcselect4) );

	exe_stage execuite (.clk(clk), .nrst(nrst), .fn4(fn4), .we4(we4), .rd4(rd4), .alu_fn4(alu_fn4), .op_a(opa), .op_b(opb),
	.alu_res5(alu_result5), .rd5(rd5), .fn5(fn5), .we5(we5), .pc4(pc4) , .B_imm4(B_imm4) ,.bneq4(bneq4) , .btype4(btype4),.b_target(b_target),
	.pcselect5(pcselect5), .pcselect4(pcselect4));

	
	commit_stage commit (.clk(clk), .nrst(nrst), .we5(we5), .rd5(rd5), .result5(alu_result5), .rd6(rd6), .wb_data6(wb6), .we6(we6));

endmodule
