module core(
	input logic clk, nrst,

	input logic DEBUG_SIG,				//DEBUG Signals from debug module to load a program
	input logic [31:0] DEBUG_addr,
	input logic [31:0] DEBUG_instr,
	input logic clk_debug
    );

	// Wires
	logic [31:0] pc, pc2, pc3, pc4, pc5, pc6;         // Program Counter Signals in each pipe 
	logic [31:0] instr2;   	   // output wire of IF stage

	logic [4:0] rs1, rs2;
	logic [1:0] B_SEL3;
	logic [31:0] opa, opb;     // operands value output from issue stage
	logic [4:0] rd3, rd4, rd5, rd6;
	logic we3, we4, we5, we6;
	logic [31:0] wb6;	   // data output from commit stage to regfile to be written

	logic [2:0] fn3, fn4, fn5, fn6;
	logic [3:0] alu_fn3, alu_fn4;
	
	logic [31:0] I_imm3, B_imm3, J_imm3, S_imm3,U_imm3;
	logic [31:0] B_imm4, J_imm4, S_imm4,U_imm4;
	logic [4:0] shamt;
	logic [31:0] U_imm6,AU_imm6;

	logic [1:0] pcselect3, pcselect4, pcselect5;	
	logic [31:0] target;

	logic btype3,btype4;
	logic bneq3,bneq4;
	logic LUI3,LUI4;
	logic auipc3,auipc4;
	logic [1:0]stallnum;

	
	 
	
	logic [3:0] mem_op3, mem_op4;
	logic [31:0] mem_out6;
	logic addr_misaligned6;

	logic [2:0] mulDiv_op4, mulDiv_op3;
	logic [31:0] mul_div6;	
	
	// Signals transfered from Execute results to Commit stage (Fall Throught)
	logic [31:0] wb_data6;	
	logic we6Issue;
	logic [4:0] rd6Issue;
	
	//Scoreboared Logic 
	logic stall;
	logic bjtaken;
	logic [6:0] opcode3;

	// =============================================== //
	//			FrontEnd Stage		   //
	// =============================================== //	
    
	// instantiating stages (7 pipelines)
	frontend_stage frontend(
	.clk            (clk),
	.nrst           (nrst),
	
	// Branch Select and Branch Target
	.PCSEL          (pcselect5),	
	.target         (target),
	
	// Outputs to Decode Stage
	.pc2            (pc2),		// pc at instruction mem pipe #2
	.instr2         (instr2),	// instruction output from inst memory (to decode stage)
	
	//DEBUG Signals from debug module to load a program
	.DEBUG_SIG      (DEBUG_SIG),
	.DEBUG_addr     (DEBUG_addr),
	.DEBUG_instr    (DEBUG_instr),
	.clk_debug      (clk_debug),
	
	//Scoreboared Signals
	.stall          (stall),
	.stallnumin      (stallnum)
	);

	// =============================================== //
	//			Decode Stage		   //
	// =============================================== //

	instdec_stage instdec (
	.clk          (clk),
	.nrst         (nrst),
	
	// Inputs from FrontEnd Stage
	.instr2       (instr2),	
	.pc2          (pc2),	
	
	// Outputs to Issue Stage 
	.rs1          (rs1),
	.rs2          (rs2),	// op registers addresses
	.rd3          (rd3),	// dest address
	.B_SEL3       (B_SEL3),
	
	.fn3          (fn3),
	.alu_fn3      (alu_fn3),

	.we3          (we3),
	// Branch and ither instructions Signals
	.bneq3        (bneq3),
	.btype3       (btype3),
	.jr3          (jr3),
	.j3           (j3),		// control signals
	.LUI3         (LUI3),
	.auipc3       (auipc3),
	// Immediates
	.shamt        (shamt),	// shift amount I_imm
	.I_imm3       (I_imm3),	// I_immediate
	.B_imm3       (B_imm3),	// B_immediate
	.J_imm3       (J_imm3),
	.U_imm3       (U_imm3),
	.S_imm3       (S_imm3),
	// Memoruy Signals
	.mem_op3      (mem_op3),
	// Multiuplier Signals
	.mulDiv_op3   (mulDiv_op3),
	// Program Counter Piping
	.pc3          (pc3),
	.pcselect3    (pcselect3),
	
	// Scoreboared Signals
	.stall          (stall),
	.opcode3 	(opcode3),
	.stallnumin	(stallnum)
	);

	// =============================================== //
	//			Issue Stage		   //
	// =============================================== //

	issue_stage issue (
	.clk          (clk),
	.nrst         (nrst),
	
	// Write Back address, enable, and data from commit stage
	.we6          (we6Issue),		
	.rdaddr6      (rd6Issue),	    
	.wb6          (wb6),		
	
	// Inputs from decode stage
	.rs1          (rs1),
	.rs2          (rs2),		// addresses of operands (to regfile)	
	.rd3          (rd3),		// rd address will be pipelined to commit stage
	.B_SEL3       (B_SEL3),		// B_SEL for op_b or I_immediates

	.fn3          (fn3),
	.alu_fn3      (alu_fn3),	// alu control from decode stage

	.we3          (we3),

	.shamt        (shamt),
	.I_imm3       (I_imm3),
	.B_imm3       (B_imm3),
	.J_imm3       (J_imm3),		// immediates sign extended
	.U_imm3       (U_imm3),
	.S_imm3       (S_imm3),

	.bneq3        (bneq3),
	.btype3       (btype3),		// we enable for regfile & fn for result selection (from pipe #3)

	.j3           (j3),
	.jr3          (jr3),
	.LUI3         (LUI3),
	.auipc3       (auipc3),
	
	.mem_op3      (mem_op3),
	.mulDiv_op3   (mulDiv_op3), 

	.pc3          (pc3),
	.pcselect3    (pcselect3),

	// Outputs
	.op_a         (opa),
	.op_b         (opb),		// operands A & B output from regfile in PIPE #4 (to exe stage)
	
	.rd4          (rd4),
	.we4          (we4),

	.fn4          (fn4),
	.alu_fn4      (alu_fn4),	// alu control in issue stage
	
	.bneq4        (bneq4),
	.btype4       (btype4),		// function selection ctrl in issue stage and write enable
			
	.B_imm4       (B_imm4),
	.J_imm4       (J_imm4),
	.S_imm4       (S_imm4),
	.U_imm4       (U_imm4),

	.j4           (j4),
	.jr4          (jr4),
	.LUI4         (LUI4),
	.auipc4       (auipc4),

	.mem_op4      (mem_op4),
	.mulDiv_op4   (mulDiv_op4),

	.pc4          (pc4),
	.pcselect4    (pcselect4),
	
	// Scoreboared Signals
	.stall          (stall),
	.bjtaken	(bjtaken),
	.opcode3	(opcode3),
	.stallnum	(stallnum)
    );

	// =============================================== //
	//			Execute Stage		   //
	// =============================================== //

   	 exe_stage execute (
	.clk          (clk),
	.nrst         (nrst),
	
	.op_a         (opa),
	.op_b         (opb),            // operands a and b from issue stage

	.fn4          (fn4),
	.alu_fn4      (alu_fn4),

	.rd4          (rd4),            // rd address from issue stage
	.we4          (we4),

	.bneq4        (bneq4),
	.btype4       (btype4),

	.B_imm4       (B_imm4),
	.J_imm4       (J_imm4),
	.S_imm4       (S_imm4),
	.U_imm4       (U_imm4),

	
	.j4           (j4),
	.jr4          (jr4),
	.LUI4         (LUI4),
	.auipc4       (auipc4),

	.mem_op4      (mem_op4),
	.mulDiv_op4   (mulDiv_op4),
	
	.pc4          (pc4),
	.pcselect4    (pcselect4),

	// Outputs
	.rd6          		(rd6),
	.we6          		(we6),
	
	.U_imm6       		(U_imm6),
	.AU_imm6       		(AU_imm6),
	
	//.mem_out6     		(mem_out6),
	.addr_misaligned6 	(addr_misaligned6),

	.mul_divReg6         	(mul_div6),
	
	.wb_data6		(wb_data6),
	.pc6              	(pc6),
	.pcselect5    		(pcselect5),
	.target       		(target),
	//signal to scoreboard
	.bjtaken6		(bjtaken)
	);

	// =============================================== //
	//			Commit Stage		   //
	// =============================================== //

	commit_stage commit(
	.clk         (clk),
	.nrst        (nrst),

	
	.rd6         (rd6),
	.we6          (we6),	  
	.wb_data6    (wb6),	        // final output that will be written back in register file PIPE #6
	
	.we6Issue        (we6Issue),
	.rd6Issue   (rd6Issue),
	.result6(wb_data6),
	
	.pc6         (pc6)
	);
    
endmodule
