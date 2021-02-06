module instdec_stage(
	input logic clk, nrst,

	input logic  [31:0] pc2,		  // input from frontend stage (pc)
	input logic  [31:0] instr2,		  // input from frontend stage (inst mem)
 
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
    output logic [3:0] mulDiv_op3,

	// Program Counter Select Piped to Execute Unit
	// until Branch and Jumps target is calculated
	output logic [1:0] pcselect3,
	
	// Scoreboard Signals
	input logic stall,bigstallwire,
	output logic [6:0]opcode3,
	input logic [1:0]stallnumin,
	input logic stall_mem,
	input logic arb_eqmem,
	input logic memOp_done
    );

	// Wires
	logic [6:0] opcode;
	logic [2:0] funct3;
	logic [6:0] funct7;
	logic instr_30;
    
	// Registers
	logic [31:0] instrReg3;	
	logic [31:0] pcReg3;	
    
	// =============================================== //
	//			Pipe 3			   //
	// =============================================== //
	always_ff @(posedge clk , negedge nrst)
	begin
	if (!nrst)
	begin
            instrReg3 		<= 0;
            pcReg3		<= 0;

	end
	else
	begin
	if ( stall&& !stallnumin[1] && !stallnumin[0]) 
	begin 
		instrReg3	<=instrReg3;
		pcReg3		<=pcReg3;
	end
	else if(stall && stallnumin[1] && !stallnumin[0] && !bigstallwire ) 
	begin 
		instrReg3	<=instrReg3;
		pcReg3		<=pcReg3;
	end 
 	else if(stall&& !stallnumin[1] && stallnumin[0] && ~bigstallwire ) 
	begin 
		instrReg3	<= instr2;
		pcReg3		<=pc2;
	end 

	else if(stall&& stallnumin[1] && !stallnumin[0] ) //01
	begin 
		instrReg3	<= instr2;
		pcReg3		<=pc2;
	end 
	else if(!stall &&!stallnumin[1] && stallnumin[0] ) 
	begin 
		instrReg3	<= instr2;
		pcReg3		<=pc2;
	end 
	else if(stall  || stall_mem ||  ( arb_eqmem && ~memOp_done ) ) 
	begin 
		instrReg3	<=instrReg3;
		pcReg3		<=pcReg3;
	end 
	else 
	begin 
		instrReg3	<= instr2;
		pcReg3		<=pc2;
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
    
	
	assign opcode   = instrReg3[6:0];
	assign funct3   = instrReg3[14:12];
	assign funct7   = instrReg3[31:25];
	assign instr_30 = instrReg3[30];
	assign opcode3  = opcode;

	instr_decoder c1 (
	.op          (opcode),
	.funct3      (funct3),
	.funct7      (funct7),
	.instr_30    (instr_30),		// instr[30]

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
	.auipc       (auipc3)
	
	
	
    );
    
endmodule
