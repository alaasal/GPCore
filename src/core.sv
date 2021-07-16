`timescale 1ns/1ns

/*`include "frontend_stage.sv"
`include "decode_stage.sv"
`include "issue_stage.sv"
`include "execute_stage.sv"
`include "commit_stage.sv"

`include "instr_decoder.sv"
`include "regfile.sv"
`include "scoreboard_data_hazards.sv"
`include "csr_regfile.sv"
`include "csr.sv"
`include "ALU.sv"
`include "branch_unit.sv"
`include "mem_wrap.sv"
`include "mul_div.sv"*/

module core(
	input logic clk, nrst,


	//OpenPiton Request
	output logic[4:0] transducer_l15_rqtype,
	output logic[2:0] transducer_l15_size,
	output logic[31:0] transducer_l15_address,
	output logic[63:0] transducer_l15_data,
	output logic transducer_l15_val,
	input logic l15_transducer_ack,
	input logic l15_transducer_header_ack,


	//OpenPiton Response
	input logic l15_transducer_val,
	input logic[63:0] l15_transducer_data_0,
	input logic[63:0] l15_transducer_data_1,
	input logic[4:0] l15_transducer_returntype,
	output logic transducer_l15_req_ack,

	// Asynchronus interrupt
	input logic external_interrupt
    );

	// Wires
	logic [31:0] pc, pc2, pc3, pc4, pc6;         // Program Counter Signals in each pipe
	logic [31:0] instr2;   	   // output wire of IF stage

	logic [4:0] rs1, rs2, rs1_4;
	logic [1:0] B_SEL3;
	logic [31:0] opa, opb;     // operands value output from issue stage
	logic [4:0] rd3, rd4, rd6;
	logic we3, we4, we6;
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


	logic [3:0] mem_op3, mem_op4;



  
        logic ld_addr_misaligned6;
        logic samo_addr_misaligned6;

	logic [3:0] mulDiv_op4, mulDiv_op3;
	logic [31:0] mul_div6;

	// Signals transfered from Execute results to Commit stage (Fall Throught)
	logic [31:0] wb_data6;
	logic we6Issue;
	logic [4:0] rd6Issue;

	//Scoreboared Logic
	logic stall,discard,nostall;

	logic [1:0]killnum;
	logic bjtaken;
	logic exception;
	logic [6:0] opcode3;

// Exceptions and CSRs
logic [11:0] csr_addr3, csr_addr4, csr_wb_addr, csr_wb_addr6;
logic [2:0] funct3_3, funct3_4;
logic [31:0] csr_imm3, csr_imm4, csr_data, csr_wb6, m_cause6, csr_wb, pc_exc, cause6;
logic instruction_addr_misaligned2, instruction_addr_misaligned3, instruction_addr_misaligned4;
logic ecall3, ecall4, ebreak3, ebreak4, mret3, mret4, mret6, sret3, sret4, sret6, uret3, uret4, uret6;
logic illegal_instr3, illegal_instr4;
logic exception_pending, exception_pending6;
logic [31:0] epc, cause;
logic m_ret, s_ret, u_ret;
logic [1:0] current_mode;
logic s_timer, m_timer, m_eie, m_tie, s_eie, s_tie, m_interrupt, s_interrupt, u_interrupt;
logic csr_we3, csr_we4, csr_we5, csr_we6,csr_we6Issue;
logic external_interrupt_w;
logic TSR;
logic illegal_flag;
// AES IP wire
logic [31:0] AES_D0, AES_D1, AES_D2, AES_D3, AES_key_addr;
logic [31:0] AES_Res0, AES_Res1, AES_Res2, AES_Res3;
logic aes_inst3, aes_inst4;
logic start_aes, aes_done;

// additional wires
logic jr3;
logic j3;
logic j4;
logic jr4;
logic u_timer;
logic u_eie;
logic u_tie;
logic u_sie;


//OpenPiton Request
logic[4:0] instr_l15_rqtype;
logic[2:0] instr_l15_size;
logic[31:0] instr_l15_address;
logic[63:0] instr_l15_data;
logic instr_l15_val;
logic l15_instr_ack;
logic l15_instr_header_ack;


//OpenPiton Response
logic l15_instr_val;
logic[63:0] l15_instr_data_0;
logic[63:0] l15_instr_data_1;
logic[3:0] l15_instr_returntype;
logic instr_l15_req_ack;

//OpenPiton Request
logic[4:0] mem_l15_rqtype;
logic[2:0] mem_l15_size;
logic[31:0] mem_l15_address;
logic[63:0] mem_l15_data;
logic mem_l15_val;
logic l15_mem_ack;
logic l15_mem_header_ack;


//OpenPiton Response
logic l15_mem_val;
logic[63:0] l15_mem_data_0;
logic[63:0] l15_mem_data_1;
logic[3:0] l15_mem_returntype;
logic mem_l15_req_ack;

//Mem to Piton
logic[1:0] state_reg;

/***********************************************************
# Arbiter to pretend like cache has two ports
States:
0: No memOps and Instruction fetch is connected to cache
1: There is a memOps waiting to get access to cache
2: data mem is connected to cache
************************************************************/
logic[1:0] arb_state;
localparam[1:0]   // 3 states are required for Moore
arb_instr = 0,
arb_wait = 1,
arb_mem = 2;
logic dmem_waiting;
logic dmem_finished;
logic instr_left_cache;
logic noMore_memOps;
logic stall_mem;
logic arb_eqmem;
logic memOp_done;
//assign stall_mem = (arb_state == arb_wait) ;
//assign arb_eqmem = (arb_state == arb_mem);
assign dmem_waiting = |mem_op3;
assign dmem_finished = (arb_state == arb_mem) && (l15_transducer_val || l15_transducer_ack ) ;
assign noMore_memOps = !(|mem_op3 );
assign instr_left_cache = (arb_state == arb_wait)&& l15_transducer_val;

/***********************
1- Stall issue stage when there is
mem op in the exc stage // stall the instru2 from frontend
until the memop finish
Exce_stage_output (memOp_done)
store (l15_mem_ack)
load (resp_fire)

2- Stall issue stage when there is
memOp in the issue but the datamem is
not connected to the cache
datamem is not connected when (arb_state !=
arb_mem)

3- When (arb_state == arb_wait) discard cache_to_
intruction_fetch and don't update pc then stall until
(arb_state == arb_instr)
********************************************/

always_ff @(posedge clk or negedge nrst) begin
if (!nrst) begin
	arb_state <= arb_instr;
	stall_mem <=0;
	arb_eqmem <=0;
	end
else
begin
    case(arb_state)
	arb_instr:
	begin
		if(dmem_waiting && ~(stall && nostall))
		begin
			arb_state <= arb_wait;
			stall_mem <=1;
		end
	end
	arb_wait:
	begin
		if(state_reg == 2'b10) //response
		begin
			if(instr_left_cache)
				begin
					arb_state <= arb_mem;

				end
		end
	end
	arb_mem:
	begin
		arb_eqmem<=1;
		stall_mem <=0;
		if(memOp_done && noMore_memOps)
			begin
			arb_state <= arb_instr;
			arb_eqmem <=0;
			end
	end
endcase
end
end



always_comb
begin

if( arb_state == arb_instr )
	begin

	//OpenPiton Request
	transducer_l15_rqtype	        = instr_l15_rqtype;
	transducer_l15_size 	        = instr_l15_size;
	transducer_l15_address  	= instr_l15_address;
	transducer_l15_data		= instr_l15_data;
	transducer_l15_val 		= instr_l15_val;
	l15_instr_ack 			= l15_transducer_ack;
	l15_instr_header_ack   	        = l15_transducer_header_ack;

	//
	l15_mem_header_ack              = 0;

	//OpenPiton Response
	l15_instr_val			= l15_transducer_val;
	l15_instr_data_0		= l15_transducer_data_0;
	l15_instr_data_1		= l15_transducer_data_1;
	l15_instr_returntype		= l15_transducer_returntype;
	transducer_l15_req_ack	 	= instr_l15_req_ack;

	//
	l15_mem_val 			= 0;
	end

else if (arb_state == arb_wait)
begin
	// Appear unready for both instr and data mem
	l15_instr_header_ack 		= 0;
	l15_mem_header_ack 		= 0;
	transducer_l15_val 		= 0;

	// Send the coming response to the instr fetch
	l15_instr_val			= l15_transducer_val;
	l15_instr_data_0		= l15_transducer_data_0;
	l15_instr_data_1		= l15_transducer_data_1;
	l15_instr_returntype		= l15_transducer_returntype;
	transducer_l15_req_ack 		= instr_l15_req_ack;
	l15_instr_ack 			= l15_instr_ack;
end

else
    begin

    //OpenPiton Request
	transducer_l15_rqtype 		= mem_l15_rqtype;
	transducer_l15_size 		= mem_l15_size;
	transducer_l15_address 		= mem_l15_address;
	transducer_l15_data		= mem_l15_data;
	transducer_l15_val 		= mem_l15_val;
	l15_mem_ack 			= l15_transducer_ack;
	l15_mem_header_ack  	        = l15_transducer_header_ack;

	//
	l15_instr_header_ack 		= 0;

	//OpenPiton Response
	l15_mem_val 			= l15_transducer_val;
	l15_mem_data_0 			= l15_transducer_data_0;
	l15_mem_data_1			= l15_transducer_data_1;
	l15_mem_returntype		= l15_transducer_returntype;
	transducer_l15_req_ack		= mem_l15_req_ack;

	//
	l15_instr_val 			= 0;
    end
end

/***********************************************************/

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

	// exceptions to control pc
	.exception_pending(exception_pending),
	.epc		(epc),

	// Outputs to Decode Stage
	.pc2            (pc2),		// pc at instruction mem pipe #2
	.instr2         (instr2),	// instruction output from inst memory (to decode stage)
	.illegal_flag   (illegal_flag),

	//Scoreboared Signals
	.stall          (stall),

	.killnum			(killnum),
	.discardwire(discard),
	.nostall(nostall),

    .l15_transducer_ack                 (l15_instr_ack),
    .l15_transducer_header_ack          (l15_instr_header_ack),

    .transducer_l15_rqtype              (instr_l15_rqtype),
    .transducer_l15_size                (instr_l15_size),
    .transducer_l15_val                 (instr_l15_val),
    .transducer_l15_address             (instr_l15_address),
    .transducer_l15_data                (instr_l15_data),


    .l15_transducer_val                 (l15_instr_val),
    .l15_transducer_returntype          (l15_instr_returntype),

    .l15_transducer_data_0              (l15_instr_data_0),
    .l15_transducer_data_1              (l15_instr_data_1),

    .transducer_l15_req_ack             (instr_l15_req_ack),

	.state_reg      (state_reg),
	.stall_mem 	(stall_mem),
	.arb_eqmem	(arb_eqmem),
	.memOp_done 	(memOp_done),

	// Exceptions
	.instruction_addr_misaligned2	(instruction_addr_misaligned2)
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
	.exception_pending(exception_pending),
	.instruction_addr_misaligned2(instruction_addr_misaligned2),
	.illegal_flag (illegal_flag),
	
	.TSR          (TSR), // input from issue stage
	.current_mode (current_mode),

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

	.stall_mem 	(stall_mem),
	.arb_eqmem	(arb_eqmem),
	.memOp_done 	(memOp_done),

	.discardwire(discard),
	.nostall(nostall),

	// csr operations
	.funct3_3	(funct3_3),
	.csr_addr3	(csr_addr3),
	.csr_imm3	(csr_imm3),

	// Exceptions
	.instruction_addr_misaligned3(instruction_addr_misaligned3),
	.ecall3		(ecall3),
	.ebreak3	(ebreak3),
	.illegal_instr3 (illegal_instr3),
	.mret3		(mret3),
	.sret3		(sret3),
	.uret3		(uret3),
	.csr_we3  	(csr_we3),
	// aes inst.
	.aes_inst3 (aes_inst3)
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

	.csr_wb		(csr_wb),
	.csr_we6 (csr_we6Issue),
	.csr_wb_addr	(csr_wb_addr),
	.cause		(cause),
	.exception_pending(exception_pending),
	.pc_exc		(pc_exc),
	.m_ret		(m_ret),
	.s_ret		(s_ret),
	.u_ret		(u_ret),
	.m_interrupt(m_interrupt),
    	.s_interrupt(s_interrupt),
	.u_interrupt(u_interrupt),

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

	.funct3_3	(funct3_3),
	.csr_addr3	(csr_addr3),
	.csr_imm3	(csr_imm3),
	.csr_we3 (csr_we3),

	.instruction_addr_misaligned3(instruction_addr_misaligned3),
	.ecall3		(ecall3),
	.ebreak3	(ebreak3),
	.illegal_instr3 (illegal_instr3),

	.mret3		(mret3),
	.sret3		(sret3),
	.uret3		(uret3),
	
	.aes_inst3 (aes_inst3),

	// Outputs
	.op_a         (opa),
	.op_b         (opb),		// operands A & B output from regfile in PIPE #4 (to exe stage)

	.rd4          (rd4),
	.rs1_4        (rs1_4),
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
	.killnum 			(killnum),
	.bjtaken	(bjtaken),
	.exception (exception),
	.opcode3	(opcode3),

	.stall_mem 	(stall_mem),
	.arb_eqmem	(arb_eqmem),
	.memOp_done 	(memOp_done),
	.discard(discard),
	.nostall(nostall),
	// csr
	.csr_data	(csr_data),
	.funct3_4	(funct3_4),
	.csr_addr4	(csr_addr4),
	.csr_imm4	(csr_imm4),
	.csr_we4  (csr_we4),

	// exceptions
	.instruction_addr_misaligned4(instruction_addr_misaligned4),
	.ecall4		(ecall4),
	.ebreak4	(ebreak4),
	.illegal_instr4 (illegal_instr4),
	.epc		(epc),

	.mret4		(mret4),
	.sret4		(sret4),
	.uret4		(uret4),

	.current_mode(current_mode),
	.s_timer(s_timer),
	.m_timer(m_timer),
	.s_eie(s_eie),
	.m_eie(m_eie),
	.m_tie(m_tie),
	.s_tie(s_tie),

	.u_timer(u_timer),
  	.u_eie(u_eie),
	.u_tie(u_tie),
	.u_sie(u_sie),
	.TSR(TSR),
	
	.AES_D0_O(AES_D0),
	.AES_D1_O(AES_D1),
	.AES_D2_O(AES_D2),
	.AES_D3_O(AES_D3),
	.AES_key_addr_O(AES_key_addr),
	
	.AES_Res0_i(AES_Res0),
	.AES_Res1_i(AES_Res1),
	.AES_Res2_i(AES_Res2),
	.AES_Res3_i(AES_Res3),
	.aes_done(aes_done),
	
	.aes_inst4(aes_inst4)

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
	.rs1_4        (rs1_4),
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
	.stall_mem 	(stall_mem),
	.dmem_finished (dmem_finished),

	.funct3_4	(funct3_4),
	.csr_data	(csr_data),
	.csr_imm4	(csr_imm4),
	.csr_addr4	(csr_addr4),
	.csr_we4  (csr_we4),

	.instruction_addr_misaligned4(instruction_addr_misaligned4),
	.ecall4		(ecall4),
	.ebreak4	(ebreak4),
	.illegal_instr4	(illegal_instr4),
	.mret4		(mret4),
	.sret4		(sret4),
	.uret4		(uret4),
	.external_interrupt(external_interrupt),
	//.excep6(exception_pending),
	
	.aes_inst4(aes_inst4),

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
    .memOp_done            (memOp_done),
    .ld_addr_misaligned6   (ld_addr_misaligned6),
    .samo_addr_misaligned6 (samo_addr_misaligned6),


	//signal to scoreboard
	.bjtaken6		(bjtaken),
	.exception (exception),

	// to csr_regfile
	//.pc_exc			(pc6),
	.exception_pending	(exception_pending6),
	.cause6			(cause6),
	.csr_wb			(csr_wb6),
	.csr_wb_addr	(csr_wb_addr6),
	.csr_we6     (csr_we6),
	.mret6			(mret6),
	.sret6			(sret6),
	.uret6			(uret6),

	.current_mode(current_mode),
	.s_timer(s_timer),
	.m_timer(m_timer),
	.s_eie(s_eie),
	.m_eie(m_eie),
	.m_tie(m_tie),
	.s_tie(s_tie),
  	.m_interrupt(m_interrupt),
  	.s_interrupt(s_interrupt),
	.u_interrupt(u_interrupt),

  	.u_timer(u_timer),
  	.u_eie(u_eie),
	.u_tie(u_tie),
	.u_sie(u_sie),
	.start_aes(start_aes)
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

	.csr_wb6	(csr_wb6),
	.csr_wb_addr6	(csr_wb_addr6),
	.csr_we6      	(csr_we6),
	.cause6		(cause6),
	.exception_pending6(exception_pending6),
	.mret6		(mret6),
	.sret6		(sret6),
	.uret6		(uret6),

	.pc6         	(pc6),

	.we6Issue       (we6Issue),
	.rd6Issue   	(rd6Issue),
	.result6	(wb_data6),

	.csr_wb		(csr_wb),
	.csr_wb_addr	(csr_wb_addr),
	.csr_we6Issue   (csr_we6Issue),
	.pc_exc		(pc_exc),
	.cause		(cause),
	.exception_pending(exception_pending),
	.mret		(m_ret),
	.sret		(s_ret),
	.uret		(u_ret)
	);
	
	// =============================================== //
	//			                  AES                        //
	// =============================================== //
	top_aes aes(
	 .clk         (clk),
	 .nrst        (nrst),
	 .start       (start_aes),
	 .key_addr    (AES_key_addr[4:0]),
	 .plaintext   ({AES_D3, AES_D2, AES_D1, AES_D0}),
	 .result      ({AES_Res3, AES_Res2, AES_Res1, AES_Res0}),
	 .done        (aes_done)
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
