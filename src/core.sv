`timescale 1ns/1ns

module core(
	input logic clk, nrst,


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
	input logic[31:0] l15_transducer_returntype,
	output logic transducer_l15_req_ack
    );

	// Wires
	logic [31:0] pc, pc2, pc3, pc4, pc6;         // Program Counter Signals in each pipe 
	logic [31:0] instr2;   	   // output wire of IF stage

	logic [4:0] rs1, rs2;
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
	logic [1:0]stallnum;

	
	 
	
	logic [3:0] mem_op3, mem_op4;




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
	logic [1:0]killnum;
	logic bjtaken;
	logic [6:0] opcode3;



//OpenPiton Request
logic[4:0] instr_l15_rqtype;
logic[2:0] instr_l15_size;
logic[31:0] instr_l15_address;
logic[31:0] instr_l15_data;
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
logic[31:0] mem_l15_data;
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

always @(posedge clk, negedge nrst)
begin
if (!nrst)
	begin
	arb_state <= arb_instr;
	stall_mem <=0;
	arb_eqmem <=0;
	end 
else
begin


end
case(arb_state)
	arb_instr: 
	begin
		if(dmem_waiting)	
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


always_comb
begin

if( arb_state == arb_instr )
	begin

	//OpenPiton Request
	transducer_l15_rqtype 	<= instr_l15_rqtype; 
	transducer_l15_size 	<= instr_l15_size;
	transducer_l15_address 	<= instr_l15_address;
	transducer_l15_data		<= instr_l15_data;
	transducer_l15_val 		<= instr_l15_val;
	l15_instr_ack 			<= l15_transducer_ack;
	l15_instr_header_ack   	<= l15_transducer_header_ack;

	//
	l15_mem_header_ack <= 0;

	//OpenPiton Response
	l15_instr_val			<= l15_transducer_val;
	l15_instr_data_0		<= l15_transducer_data_0;
	l15_instr_data_1		<= l15_transducer_data_1;
	l15_instr_returntype	<= l15_transducer_returntype;
	transducer_l15_req_ack 	<= instr_l15_req_ack;

	//
	l15_mem_val <= 0;
	end

else if (arb_state == arb_wait)
begin
	// Appear unready for both instr and data mem
	l15_instr_header_ack <= 0;
	l15_mem_header_ack <= 0;
	transducer_l15_val <= 0;

	// Send the coming response to the instr fetch
	l15_instr_val			<= l15_transducer_val;
	l15_instr_data_0		<= l15_transducer_data_0;
	l15_instr_data_1		<= l15_transducer_data_1;
	l15_instr_returntype	<= l15_transducer_returntype;
	transducer_l15_req_ack 	<= instr_l15_req_ack;
	l15_instr_ack 			<= l15_instr_ack;
end

else
    begin

    //OpenPiton Request
	transducer_l15_rqtype 	<= mem_l15_rqtype; 
	transducer_l15_size 	<= mem_l15_size;
	transducer_l15_address 	<= mem_l15_address;
	transducer_l15_data		<= mem_l15_data;
	transducer_l15_val 		<= mem_l15_val;
	l15_mem_ack 			<= l15_transducer_ack;
	l15_mem_header_ack  	<= l15_transducer_header_ack;

	//
	l15_instr_header_ack <= 0;

	//OpenPiton Response
	l15_mem_val 			<= l15_transducer_val;
	l15_mem_data_0 			<= l15_transducer_data_0;
	l15_mem_data_1			<= l15_transducer_data_1;
	l15_mem_returntype		<= l15_transducer_returntype;
	transducer_l15_req_ack	<= mem_l15_req_ack;

	//
	l15_instr_val <= 0;
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
	
	// Outputs to Decode Stage
	.pc2            (pc2),		// pc at instruction mem pipe #2
	.instr2         (instr2),	// instruction output from inst memory (to decode stage)
	
	//Scoreboared Signals
	.stall          (stall),
	.stallnumin      (stallnum),
	.killnum			(killnum),
	 
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
	
	.state_reg (state_reg),
	.stall_mem 	(stall_mem),
	.arb_eqmem	(arb_eqmem),
	.memOp_done 	(memOp_done)	
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
	.stallnumin	(stallnum),
	.stall_mem 	(stall_mem),
	.arb_eqmem	(arb_eqmem),
	.memOp_done 	(memOp_done)	
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
	.killnum 			(killnum),
	.bjtaken	(bjtaken),
	.opcode3	(opcode3),
	.stallnum	(stallnum),
	.stall_mem 	(stall_mem),
	.arb_eqmem	(arb_eqmem),
	.memOp_done 	(memOp_done)	
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
    .memOp_done            (memOp_done),
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

