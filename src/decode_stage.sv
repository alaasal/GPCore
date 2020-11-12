module instdec_stage(
	input logic clk, nrst,

	input logic  [31:0] pc2,		  // input from frontend stage (pc)
	input logic  [31:0] instr2,		  // input from frontend stage (inst mem)

	input logic exception_pending,	// from commit stage

	input logic instruction_addr_misaligned2,  // exception from frontend

	// Operands and Destination
	output logic [4:0] rs1, rs2,
	output logic [4:0] rd3,

	// Operands Select Sginals
	output logic [1:0] B_SEL3,

	// Instruction Immediate
	output logic [31:0] I_imm3,		  //Arithemtic, Jump, and Load Immediate
	output logic [31:0] B_imm3,		  //Branch Immediate
	output logic [31:0] J_imm3,		  //Jumps Immediate
	output logic [31:0] U_imm3,		  //LUI & AUIPC Immediate
	output logic [31:0] S_imm3,		  //Store Immediate
	output logic [4:0]  shamt,		  //Shift Amount Immediate

	// Write back Enable
	output logic we3,

	// Branch and Jumps Control Signals
	output logic bneq3, btype3, jr3, j3,

	// Other Instr Control Signals
	output logic LUI3, auipc3,

	// Function Control Signals
	output logic [2:0] fn3,
	output logic [3:0] alu_fn3,

	// Piped Signals
   	output logic [31:0] pc3,

	// Memory Request
    	output logic [3:0] mem_op3,
	// MulDiv Operation
   	 output logic [2:0] mulDiv_op3,

	// Program Counter Select Piped to Execute Unit
	// until Branch and Jumps target is calculated
	output logic [1:0] pcselect3,

	// Scoreboard Signals
	input logic stall,
	output logic [6:0]opcode3,

	input logic [1:0]stallnumin,
	// CSR
	output logic [2:0] funct3_3,
	output logic [11:0] csr_addr3,
	output logic [31:0] csr_imm3,
	// exceptions
	output logic instruction_addr_misaligned3,
	output logic ecall3,
	output logic illegal_instr3,
	// return instructions
	output logic mret3, sret3, uret3,
	// Write back csr_regfile Enable
	output logic csr_we3
    );

	// Wires
	logic [6:0] opcode;
	logic [2:0] funct3;
	logic [6:0] funct7;
	logic instr_30;

	// Registers
	logic [31:0] instrReg3;
	logic [31:0] pcReg3;

	// Exception
	logic instruction_addr_misalignedReg3;


	// =============================================== //
	//			Pipe 3			   //
	// =============================================== //
	always_ff @(posedge clk , negedge nrst)
	  begin
		if (!nrst)
	  	  begin
            		instrReg3 	<= 0;
            		pcReg3		<= 0;
			instruction_addr_misalignedReg3 <= 0;
	  	  end
		else
		  begin
			if ( stall&& !stallnumin[1] && !stallnumin[0])
			  begin
				instrReg3	<=instrReg3;
				pcReg3		<=pcReg3;
				instruction_addr_misalignedReg3	<= instruction_addr_misalignedReg3;
			  end

			else if(stall&& stallnumin[1] && !stallnumin[0] )
			  begin
				instrReg3	<=instrReg3;
				pcReg3		<=pcReg3;
				instruction_addr_misalignedReg3	<= instruction_addr_misalignedReg3;
			  end

			else if(!stall &&!stallnumin[1] && stallnumin[0] )
			  begin
				instrReg3	<= instr2;
				pcReg3		<=pc2;
				instruction_addr_misalignedReg3	<= instruction_addr_misaligned2;
			  end
			else if(stall )
			  begin
				instrReg3	<=instrReg3;
				pcReg3		<=pcReg3;
				instruction_addr_misalignedReg3	<= instruction_addr_misalignedReg3;
			  end
			else
			  begin
				instrReg3	<= instr2;
				pcReg3		<=pc2;
				instruction_addr_misalignedReg3	<= instruction_addr_misaligned2;
			  end
		  end
	  end


	// =============================================== //
	//			 Outputs		   //
	// =============================================== //
	assign rs1      = instrReg3[19:15];
	assign rs2      = instrReg3[24:20];
	assign rd3      = instrReg3[11:7];
	assign shamt    = instrReg3[24:20];
	assign I_imm3   = 32'(signed'(instrReg3[31:20]));  // sign extended I_immediate to 32-bit
	assign B_imm3	= 32'(signed'({instrReg3[31], instrReg3[7], instrReg3[30:25], instrReg3[11:8], 1'b0 })); //sign extending b_immediate to 32-bit
	assign J_imm3	= 32'(signed'({instrReg3[31], instrReg3[19:12], instrReg3[20], instrReg3[30:21], 1'b0}));
	assign U_imm3   = 32'(signed'({instrReg3[31:12] , {12'b0}}));
	assign S_imm3   = 32'(signed'({instrReg3[31:25], instrReg3[11:7]}));
	assign pc3 	= pcReg3;

	// Exception
	assign instruction_addr_misaligned3 = instruction_addr_misalignedReg3;


	assign opcode   = instrReg3[6:0];
	assign funct7   = instrReg3[31:25];
	assign funct12	= instrReg3[31:20];
	assign funct3   = instrReg3[14:12];
	assign instr_30 = instrReg3[30];
	assign opcode3  = opcode;
	// to csr_unit
	assign csr_addr3 = instrReg3[31:20];
	assign csr_imm3	 = instrReg3[19:15];
	assign funct3_3  = instrReg3[14:12];

	instr_decoder c1 (
	.op          (opcode),
	.funct3      (funct3),
	.funct7      (funct7),
	.funct12     (funct12),
	.instr_30    (instr_30),		// instr[30]
	.exception_pending(exception_pending),

	.pcselect    (pcselect3),		// Select pc source
	.we          (we3),				// Regfile write enable
	.B_SEL       (B_SEL3),			// Select Operand B at the end of the issue stage
	.alu_fn      (alu_fn3),			// Select alu operation
	.fn          (fn3),				// Select Function Unit
	.bneq        (bneq3),			// to alu beq ~ bneq
	.btype       (btype3),
	.mulDiv_op   (mulDiv_op3),      //m extension opcode
	.j           (j3),
	.jr          (jr3),
	.mem_op      (mem_op3),
	.LUI         (LUI3),
	.auipc       (auipc3),
	.ecall       (ecall3),
	.uret        (uret3),
	.sret        (sret3),
	.mret        (mret3),
	.wfi	     (),
	.illegal_instr(illegal_instr3),
	.csr_we(csr_we3)
    );

endmodule
