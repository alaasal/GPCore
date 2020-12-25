`timescale 1ns/1ns

module core(
	input logic clk, nrst,

	input logic DEBUG_SIG,				//DEBUG Signals from debug module to load a program
	input logic [31:0] DEBUG_addr,
	input logic [31:0] DEBUG_instr,
	input logic clk_debug,



	//OpenPiton Request
	output logic[4:0] transducer_l15_rqtype, 
	output logic[2:0] transducer_l15_size,
	output logic[31:0] transducer_l15_address,
	output logic[31:0] transducer_l15_data,
	output logic transducer_l15_val,
	input logic l15_transducer_ack,
	input logic l15_transducer_header_ack,


	//OpenPiton Response
	input logic l15_transducer_val,
	input logic[63:0] l15_transducer_data_0, 
	input logic[63:0] l15_transducer_data_1, 
	input logic[31:0] l15_transducer_data_2, 
	input logic[31:0] l15_transducer_data_3, 
	input logic[31:0] l15_transducer_returntype,
	output logic transducer_l15_req_ack
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

	logic [2:0] fn3, fn4;
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

    //OpenPiton Memory Request
	logic [3:0] mem_l15_rqtype; 
	logic [2:0] mem_l15_size;
	logic [31:0] mem_l15_address;
	logic [31:0] mem_l15_data;
	
    logic mem_l15_val;

	//OpenPiton Memory Response
    logic [63:0] l15_mem_data_0; 
    logic [63:0] l15_mem_data_1;
    logic [3:0] l15_mem_returntype;
    
    logic l15_mem_val;
    logic l15_mem_ack;
    logic l15_mem_header_ack;
    logic mem_l15_req_ack;

    logic ld_addr_misaligned6;
    logic samo_addr_misaligned6;

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
	
	//Scoreboared Signals
	.stall          (stall),
	.stallnumin      (stallnum),
	 
	.l15_transducer_ack                 (l15_transducer_ack),
    .l15_transducer_header_ack          (l15_transducer_header_ack),

    .transducer_l15_rqtype              (transducer_l15_rqtype),
    .transducer_l15_size                (transducer_l15_size),
    .transducer_l15_val                 (transducer_l15_val),
    .transducer_l15_address             (transducer_l15_address),
    .transducer_l15_data                (transducer_l15_data),


    .l15_transducer_val                 (l15_transducer_val),
    .l15_transducer_returntype          (l15_transducer_returntype),

    .l15_transducer_data_0              (l15_transducer_data_0),
    .l15_transducer_data_1              (l15_transducer_data_1),
    .l15_transducer_data_2              (l15_transducer_data_2),
    .l15_transducer_data_3              (l15_transducer_data_3),

    .transducer_l15_req_ack             (transducer_l15_req_ack)
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
	
	.mul_divReg6         	(mul_div6),
	
	.wb_data6		(wb_data6),
	.pc6              	(pc6),
	.pcselect5    		(pcselect5),
	.target       		(target),

    //OpenPiton Request
	.mem_l15_rqtype        (mem_l15_rqtype), 
	.mem_l15_size          (mem_l15_size),
	.mem_l15_address       (mem_l15_address),
	.mem_l15_data          (mem_l15_data),
    .mem_l15_val           (mem_l15_val),

	//OpenPiton Response
	.l15_mem_data_0        (l15_mem_data_0),
    .l15_mem_data_1        (l15_mem_data_1), 
	.l15_mem_returntype    (l15_mem_returntype),
    
    .l15_mem_val           (l15_mem_val),
    .l15_mem_ack           (l15_mem_ack),
	.l15_mem_header_ack    (l15_mem_header_ack),
    .mem_l15_req_ack       (mem_l15_req_ack),
    .ld_addr_misaligned6   (ld_addr_misaligned6),
    .samo_addr_misaligned6 (samo_addr_misaligned6),
    
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

logic[31:0] pc6Tmp;
logic pc6Commit;
always_ff @(posedge clk , negedge nrst)
begin
if (!nrst)
begin
	pc6Tmp<= 32'b0;
	pc6Commit<= 0;
end
else
begin
if (pc6 == pc6Tmp)
	pc6Commit <= 0;
else
begin
	pc6Commit <= 1;
	pc6Tmp <= pc6;
end
end
end
    
endmodule

