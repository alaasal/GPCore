//`include "regfile.sv"
//`include "scoreboard_data_hazards.sv"
//`include "csr_regfile.sv"
module issue_stage (

	input logic clk, nrst,
	// Write back signals from commit stage
	input logic we6,			// Write Enable
	input logic [4:0] rdaddr6,		// Destenation Address
	input logic [31:0] wb6,			// Data
	
	// signals to csr_regfile
	input logic [31:0] csr_wb,
	input logic csr_we6,			// Write Enable to csr_regfile
	input logic [11:0] csr_wb_addr,
	input logic [31:0] cause,
	input logic exception_pending,
	input logic [31:0] pc_exc,
	input logic m_ret, s_ret, u_ret,
	input logic m_interrupt, s_interrupt, u_interrupt,

	// Piped Signals from Decode to Issue
	input logic we3,
	input logic bneq3,
	input logic  btype3,
	input logic [6:0] opcode3,

	input logic [2:0] fn3,
	input logic [3:0] alu_fn3,		// ALU control from decode stage

	input logic [4:0] rs1, rs2,		// Addresses of operands (to regfile)
	input logic [4:0] rd3,			// Write address will be pipelined to commit stage
	input logic [1:0] B_SEL3, 		// B_SEL for op_b or I_immediates

	input logic [31:0] I_imm3,		//Immediates
	input logic [31:0] B_imm3,
	input logic [31:0] J_imm3,
	input logic [31:0] S_imm3,
	input logic [31:0] U_imm3,
	input logic [4:0] shamt,

	// to csr_unit in execute stage
	input logic [2:0] funct3_3,
	input logic [11:0] csr_addr3,
	input logic [31:0] csr_imm3,
	// write back csr_regfile enable
	input logic csr_we3,

	// exceptions
	input logic instruction_addr_misaligned3,
	input logic ecall3, ebreak3,
	input logic illegal_instr3,
	input logic mret3, sret3, uret3,

	input logic j3,
	input logic jr3,
	input logic LUI3,
	input logic auipc3,

	input logic [3:0] mem_op3,
	input logic [3:0] mulDiv_op3,

	input logic [31:0] pc3,
	input logic [1:0] pcselect3,


	// Piped Signals Ended

	// Register File Outputs
	output logic [31:0] op_a,
	output logic [31:0] op_b,

	// Piped Signals from Issue to Execute
	output logic [4:0] rd4,
	output logic [4:0] rs1_4, // to execute stage -> csr_unit
	output logic [3:0] alu_fn4,
	output logic [2:0] fn4,

	output logic [31:0] B_imm4,
	output logic [31:0] J_imm4,
	output logic [31:0] S_imm4,
	output logic [31:0] U_imm4,

	output logic we4,
	output logic bneq4,
	output logic btype4,

	output logic j4,
	output logic jr4,
	output logic LUI4,
	output logic auipc4,

	output logic [3:0] mem_op4,

	output logic [3:0] mulDiv_op4,

	output logic [31:0] pc4,
	output logic [1:0] pcselect4,
	// Piped Signals Ended

	// Socreboard Signals
	input logic bjtaken,discard,
	output logic stall,nostall,
	output logic [1:0]killnum,
	input logic stall_mem,
	input logic arb_eqmem,
	input logic exception,
	input logic memOp_done,

	// csr
	output logic [31:0] csr_data,
	output logic [2:0] funct3_4,
	output logic [11:0] csr_addr4,
	output logic [31:0] csr_imm4,
	// write back csr_regfile enable
	output logic csr_we4,
	
  // from csr_regfile to decode stage
  output logic TSR,
  
	// exceptions
	output logic instruction_addr_misaligned4,
	output logic ecall4, ebreak4,
	output logic illegal_instr4,
	output logic [31:0] epc,	// output to frontend
	output logic mret4, sret4, uret4,

	output logic m_timer,s_timer,u_timer,

	output logic [1:0] current_mode,
	output logic m_tie, s_tie, m_eie, s_eie,u_eie,u_tie,u_sie
    );


	// Wires
	logic [31:0] operand_a, operand_b;   	   // Operands value output from the register file
	// Scoreboard Wires

	logic kill;
	// =============================================== //
	//			Pipe 4			   //
	// =============================================== //
	logic [1:0] BSELReg4;

	logic [4:0] shamtReg4;
	logic [31:0] I_immdReg4;
	logic [31:0] B_immdReg4;
	logic [31:0] J_immReg4;
	logic [31:0] S_immReg4;
	logic [31:0] U_immReg4;

	logic [4:0] rdReg4;
  logic [4:0] rs1Reg4;
  
	logic [3:0] alufnReg4;
	logic [2:0] fnReg4;

	logic weReg4;

	logic bneqReg4;
	logic btypeReg4;

	logic jReg4;
	logic jrReg4;
	logic LUIReg4;
	logic auipcReg4;

	logic [3:0] mem_opReg4;
	logic [3:0] mulDiv_opReg4;

	logic [31:0] pcReg4;
	logic [1:0] pcselectReg4;

	logic [2:0] funct3Reg4;
	logic [31:0]csr_immReg4;
	logic [11:0] csr_addrReg4;
	logic csr_weReg4;

	// Scoreboard Regs


/*********************************************
at cycle 1
frontend connected to cache (state_reg == req)
deocde intrX (stall)
issue memOp (stall) stall if (arb_state != arb_mem) feedback the wire to the decode stage


at cycle 2
frontend stalled
decode (noOp)
issue (intrX)
exce(memOp) connected to cache

################################################
#case2
frontend connected to cache (state_reg == resp)
deocde intrX (stall) stall if (arb_state != arb_mem) feedback the wire to the decode stage
issue memOp (stall)  stall if (arb_state != arb_mem) feedback the wire to the decode stage

at cycle 2+n
frontend stalled
decode (intrY)
issue (intrX)
exce(memOp) connected to cache
***********************************************
Stall#2
if there is any memOp in the exce unit stall
decode and issue until memDone
****************************************************/
// exceptions
logic instruction_addr_misalignedReg4;
logic ecallReg4, ebreakReg4;
logic illegal_instrReg4;
logic mretReg4, sretReg4, uretReg4;

	always_ff @(posedge clk, negedge nrst)
	begin
        if (!nrst)
          begin
		BSELReg4	<= 0;
		rdReg4		<= 0;
    rs1Reg4 <= 0;
    
		shamtReg4 	<= 0;
		I_immdReg4	<= 0;
		B_immdReg4	<= 0;
		J_immReg4	<= 0;
		S_immReg4       <= 0;
		U_immReg4       <= 0;

		alufnReg4	<= 0;
		fnReg4		<= 0;

		weReg4		<= 0;

		bneqReg4	<= 0;
		btypeReg4	<= 0;

		jReg4 		<= 0;
		jrReg4 		<= 0;

		LUIReg4         <= 0;
		auipcReg4       <= 0;

		mem_opReg4 	<= 0;
		mulDiv_opReg4 	<= 0;

		pcReg4		<= 0;
		pcselectReg4	<= 0;
		killnum		<= 2'b0;

		funct3Reg4	<= '0;
		csr_addrReg4	<= '0;
		csr_immReg4	<= '0;
		csr_weReg4 <= 0;
		instruction_addr_misalignedReg4 <= 0;
		ecallReg4	<= 0;
		ebreakReg4	<= 0;
		illegal_instrReg4<= 0;

		mretReg4	<= 0;
		sretReg4	<= 0;
		uretReg4	<= 0;
          end
        else
          begin
    rs1Reg4 <= rs1;
    
		shamtReg4	<= shamt;
		B_immdReg4	<= B_imm3;
		J_immReg4	<= J_imm3;
		U_immReg4  	<= U_imm3;
		S_immReg4 	<= S_imm3;
		I_immdReg4	<= I_imm3;

		bneqReg4	<= bneq3;
		btypeReg4	<= btype3;

		jReg4 		<= j3;
		jrReg4 		<= jr3;
		LUIReg4     	<= LUI3;
 		auipcReg4   	<= auipc3;

		mem_opReg4 	<= mem_op3;
		mulDiv_opReg4 	<= mulDiv_op3;
		pcReg4		<= pc3;

		funct3Reg4	<= funct3_3;
		csr_immReg4	<= csr_imm3;
		csr_addrReg4	<= csr_addr3;
		instruction_addr_misalignedReg4 <= instruction_addr_misaligned3;
		ecallReg4	<= ecall3;
		ebreakReg4	<= ebreak3;
		illegal_instrReg4<= illegal_instr3;
		mretReg4	<= mret3;
		sretReg4	<= sret3;
		uretReg4	<= uret3;

		pcReg4		<= pc3;


		if(discard || (stall && nostall))
		begin
		pcselectReg4<= 2'b00;
		weReg4		<= 1'b0;
		BSELReg4	<= 2'b01;
		alufnReg4	<= 3'b000;
		fnReg4		<= 3'b000;
		I_immdReg4	<= 32'b0;
		rdReg4		<= 5'b0;
		rs1Reg4 <= 0;
		shamtReg4	<= 0;
		B_immdReg4	<= 0;
		J_immReg4	<= 0;
		U_immReg4  	<= 0;
		S_immReg4 	<= 0;
		I_immdReg4	<= 0;

		bneqReg4	<= 0;
		btypeReg4	<= 0;

		jReg4 		<= 0;
		jrReg4 		<= 0;
		LUIReg4     	<= 0;
 		auipcReg4   	<= 0;

		mem_opReg4 	<= 0;
		mulDiv_opReg4 	<= 0;

		csr_weReg4		<= 0;
		instruction_addr_misalignedReg4 <= 0;
		ecallReg4	<= 0;
		ebreakReg4	<= 0;
		illegal_instrReg4<= 0;
		mretReg4	<= 0;
		sretReg4	<= 0;
		uretReg4	<= 0;
		end
		else if(kill) begin
		  shamtReg4 	<= 0;
		  I_immdReg4	<= 0;
		  B_immdReg4	<= 0;
		  J_immReg4	<= 0;
		  S_immReg4       <= 0;
		  U_immReg4       <= 0;
		
		  bneqReg4 <= 0;
	    btypeReg4 <= 0;
	    jReg4 <= 0;
	    jrReg4 <= 0;
	    LUIReg4 <= 0;
	    auipcReg4 <= 0;
		
		killnum		<=killnum+1;
		pcselectReg4	<= 2'b00;
		weReg4		<= 1'b0;
		BSELReg4	<= 2'b01;
		alufnReg4	<= 3'b000;
		fnReg4		<= 3'b000;

		rdReg4		<= 5'b0;
		rs1Reg4 <= 0;
		
		pcReg4      <= 0;
		csr_weReg4		<= 0;
		instruction_addr_misalignedReg4 <= 0;
		ecallReg4	<= 0;
		ebreakReg4	<= 0;
		illegal_instrReg4<= 0;
		mretReg4	<= 0;
		sretReg4	<= 0;
		uretReg4	<= 0;
		end
		else if ( killnum[1] && !killnum[0])begin
		killnum		<=killnum+1;
		shamtReg4 	<= 0;
		I_immdReg4	<= 0;
		B_immdReg4	<= 0;
		J_immReg4	<= 0;
		S_immReg4       <= 0;
		U_immReg4       <= 0;
		
		bneqReg4 <= 0;
	  btypeReg4 <= 0;
	  jReg4 <= 0;
	  jrReg4 <= 0;
	  LUIReg4 <= 0;
	  auipcReg4 <= 0;
		
		pcselectReg4	<= 2'b00;
		weReg4		<= 1'b0;
		BSELReg4	<= 2'b01;
		alufnReg4	<= 3'b000;
		fnReg4		<= 3'b000;

		rdReg4		<= 5'b0;
		rs1Reg4 <= 0;
		pcReg4      <= 0;
		
		////////////////
		csr_weReg4		<= 0;
		instruction_addr_misalignedReg4 <= 0;
		ecallReg4	<= 0;
		ebreakReg4	<= 0;
		illegal_instrReg4<= 0;
		mretReg4	<= 0;
		sretReg4	<= 0;
		uretReg4	<= 0;
		///////////////
		end

		else if (stall_mem ||  ( arb_eqmem && ~memOp_done ) )
		begin
		killnum		<= 2'b0;
		BSELReg4	<= BSELReg4;
		
		rdReg4		<=rdReg4;
		rs1Reg4 <= rs1Reg4;

		shamtReg4 	<= shamtReg4;
		I_immdReg4	<= I_immdReg4;
		B_immdReg4	<= B_immdReg4;
		J_immReg4	<= J_immReg4;
		S_immReg4       <= S_immReg4;
		U_immReg4       <= U_immReg4;

		alufnReg4	<= alufnReg4;
		fnReg4		<= fnReg4;

		weReg4		<=weReg4;

		bneqReg4	<= bneqReg4;
		btypeReg4	<= btypeReg4;

		jReg4 		<= jReg4;
		jrReg4 		<=jrReg4;

		LUIReg4         <=LUIReg4;
		auipcReg4       <= auipcReg4;

		mem_opReg4 	<=mem_opReg4;
		mulDiv_opReg4 	<= mulDiv_opReg4;

		pcReg4		<= pcReg4;
		pcselectReg4	<= pcselectReg4;
		
		///////////////////////////
		csr_immReg4	<= csr_immReg4;
		csr_addrReg4	<= csr_addrReg4;
		csr_weReg4 <= csr_weReg4;
		instruction_addr_misalignedReg4 <= instruction_addr_misalignedReg4;
		ecallReg4	<= ecallReg4;
		ebreakReg4	<= ebreakReg4;
		illegal_instrReg4<= illegal_instrReg4;
		mretReg4	<= mretReg4;
		sretReg4	<= sretReg4;
		uretReg4	<= uretReg4;
		//////////////////////////////

		end
		else
		begin
		killnum		<= 2'b0;
		pcselectReg4	<= pcselect3;
		weReg4		<= we3;
		BSELReg4	<= B_SEL3;
		alufnReg4	<= alu_fn3;
		fnReg4		<= fn3;

		rdReg4		<= rd3;
		rs1Reg4 <= rs1;
		
		csr_weReg4 	<= csr_we3;

		// exceptions
		instruction_addr_misalignedReg4 <= instruction_addr_misaligned3;
		ecallReg4	<= ecall3;
		ebreakReg4	<= ebreak3;
		illegal_instrReg4<= illegal_instr3;
		mretReg4	<= mret3;
		sretReg4	<= sret3;
		uretReg4	<= uret3;
		end

        end

      end

    // register file
    regfile reg1 (
	.clk(clk),
	.clrn(nrst),
	.we(we6),
	.write_addr(rdaddr6),
	.source_a(rs1),
	.source_b(rs2),
	.result(wb6),
	.op_a(operand_a),
	.op_b(operand_b)
	);

 scoreboard_data_hazards scoreboard (
	.clk(clk),
	.nrst(nrst),
	.exception(exception),
	.btaken(bjtaken),
	.jr4(jr4),
	.rs1(rs1),
	.rs2(rs2),
	.rd(rd3),
	.op_code(opcode3),
	.stall(stall),
	.kill(kill),

	.nostall(nostall),
	.discard(discard)
	);

	// csr register file
	csr_regfile csr_registers(
	.clk(clk),
	.nrst(nrst),
	.csr_we(csr_we6),
	.csr_address_r(csr_addrReg4),
	.csr_address_wb(csr_wb_addr),
	.csr_wb(csr_wb),
	.exception_pending(exception_pending),
	.cause(cause),
	.pc_exc(pc_exc),
	.m_ret(m_ret),
	.s_ret(s_ret),
	.u_ret(u_ret),
	.csr_data(csr_data),
	.current_mode(current_mode),
	.epc(epc),
	
	.s_timer(s_timer),
	.m_timer(m_timer),
	.s_eie(s_eie),
	.m_eie(m_eie),
	.m_tie	(m_tie),
	.s_tie(s_tie),
 	.m_interrupt(m_interrupt),
  	.s_interrupt(s_interrupt),
	.u_interrupt(u_interrupt),
  	.u_timer(u_timer),
  	.u_eie(u_eie),
	.u_tie(u_tie),
	.u_sie(u_sie),
	.TSR(TSR)
	);


	// mux to select between operand b from regfile or sign extended 32-bit I_immediate (I_imm) or shamt I_imm
	always_comb
	begin
        unique case(BSELReg4)
            2'b00: op_b = operand_b;
            2'b01: op_b = I_immdReg4;
            2'b10: op_b = shamtReg4;
            default: op_b = operand_b;
        endcase
	end


	// =============================================== //
	//			 Outputs		   //
	// =============================================== //

	// Assign Operand A and Operand B to the outputs wires
	 assign op_a =  ( !(|rd4) && !(|I_immdReg4) && !(|alufnReg4) && !(|fnReg4) && ~jr3 && !(|mem_op4) )? 32'b0: operand_a;

	// Piped Signals from Decode to Execute
	// Issue acts such as a cycle delay
	// Issue stage may or may not use this signals
	assign rd4		= rdReg4;
	assign rs1_4 = rs1Reg4;

	assign B_imm4		= B_immdReg4;
	assign J_imm4		= J_immReg4;
	assign U_imm4   	= U_immReg4;
	assign S_imm4 		= S_immReg4;

	assign fn4 		= fnReg4;
	assign alu_fn4		= alufnReg4;

	assign we4 		= weReg4;

	assign bneq4		= bneqReg4;
	assign btype4		= btypeReg4;


	assign j4 		= jReg4;
	assign jr4 		= jrReg4;
	assign LUI4 		= LUIReg4;
	assign auipc4 		= auipcReg4;

	assign mem_op4 		= mem_opReg4;
	assign mulDiv_op4 	= mulDiv_opReg4;

	assign pc4		= pcReg4;
	assign pcselect4	= pcselectReg4;

	assign funct3_4		= funct3Reg4;
	assign csr_imm4		= csr_immReg4;
	assign csr_addr4	= csr_addrReg4;
	assign csr_we4 		= csr_weReg4;

	// exceptions
	assign instruction_addr_misaligned4 = instruction_addr_misalignedReg4;
	assign ecall4		= ecallReg4;
	assign ebreak4		= ebreakReg4;
	assign illegal_instr4	= illegal_instrReg4;

	assign mret4		= mretReg4;
	assign sret4		= sretReg4;
	assign uret4		= uretReg4;
	// Piped Signals ended

endmodule
