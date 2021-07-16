`define XLEN 32

/* User. */
`define U 2'b00
/* Supervisor. */
`define S 2'b01
/* Reserved. */
`define R 2'b10
/* Machine. */
`define M 2'b11

// synchronous (interrupt = 0) values are defined here.

/* Instruction address misaligned. */
`define I_ADDR_MISALIGNED   32'h0
/* Instruction access fault. */
`define I_ACCESS_FAULT      32'h1
/* Illegal instruction. */
`define I_ILLEGAL           32'h2
/* Breakpoint. */
`define BREAKPOINT          32'h3
/* Load address misaligned. */
`define L_ADDR_MISALIGNED   32'h4
/* Load access fault. */
`define L_ACCESS_FAULT      32'h5
/* Store/AMO address misaligned. */
`define S_ADDR_MISALIGNED   32'h6
/* Store/AMO access fault. */
`define S_ACCESS_FAULT      32'h7
/* Environment call from U-mode. */
`define U_CALL              32'h8
/* Environment call from S-mode. */
`define S_CALL              32'h9
/* Environment call from M-mode. */
`define M_CALL              32'hb

// asynchronous (interrupt = 1) values are defined here.

/* User software interrupt. */
`define U_INT_SW            32'h0
/* Supervisor software interrupt. */
`define S_INT_SW            32'h1
/* Machine software interrupt. */
`define M_INT_SW            32'h3
/* User timer interrupt. */
`define U_INT_TIMER         32'h4
/* Supervisor timer interrupt. */
`define S_INT_TIMER         32'h5
/* Machine timer interrupt. */
`define M_INT_TIMER         32'h7
/* User external interrupt. */
`define U_INT_EXT           32'h8
/* Supervisor external interrupt. */
`define S_INT_EXT           32'h9
/* Machine external interrupt. */
`define M_INT_EXT           32'hb

//`include"csr.sv"
//`include"ALU.sv"
//`include"branch_unit.sv"
//`include"mem_wrap.sv"
//`include"mul_div.sv"

module exe_stage(

	input logic clk, nrst,

	input logic [31:0] op_a,
 	input logic [31:0] op_b,
	input logic [4:0] rd4,			// rd address from issue stage
	input logic [4:0] rs1_4, // rs1 from issue to execute to csr_unit

	input logic [2:0] fn4,
	input logic [3:0] alu_fn4,

	input logic we4,

	input logic [31:0] B_imm4,
	input logic [31:0] J_imm4,
	input logic [31:0] U_imm4 ,
	input logic [31:0] S_imm4,

	input logic bneq4,
	input logic btype4,

	input logic j4,
	input logic jr4,
	input logic LUI4,
	input logic auipc4,

	input logic [3:0] mem_op4,
	input logic [3:0] mulDiv_op4,

	input logic [31:0] pc4,
	input logic [1:0] pcselect4,
	input logic stall_mem,dmem_finished,
	// csr
	input logic [2:0] funct3_4,
	input logic [31:0] csr_data, csr_imm4,
	input logic [11:0] csr_addr4,
	input logic csr_we4,

	// exceptions
	input logic instruction_addr_misaligned4,
	input logic ecall4, ebreak4,
	input logic illegal_instr4,
	input logic mret4, sret4, uret4,
  // aes inst.
  input logic aes_inst4,

	input logic m_timer,s_timer, u_timer,

 	input logic [1:0] current_mode,

	input logic m_tie, s_tie, m_eie, s_eie,u_eie,u_tie,u_sie,
	input logic external_interrupt,
	//input logic excep6,


	output logic [31:0] wb_data6,
	output logic we6,


	output logic [4:0] rd6,

	output logic [31:0] U_imm6,
	output logic [31:0] AU_imm6 ,

	//output logic [31:0] mem_out6,
	//output logic addr_misaligned6,

	output logic [31:0] mul_divReg6,

	output logic [31:0] target,
	output logic [31:0] pc6,
	output logic [1:0] pcselect5,

    //OpenPiton Request
	output logic [4:0] mem_l15_rqtype,
	output logic [2:0] mem_l15_size,
	output logic [31:0] mem_l15_address,
	output logic [63:0] mem_l15_data,
    output logic mem_l15_val,

	//OpenPiton Response
	input logic [63:0] l15_mem_data_0,
    input logic [63:0] l15_mem_data_1,
	input logic [3:0] l15_mem_returntype,
    input logic l15_mem_val,
    input logic l15_mem_ack,
	input logic l15_mem_header_ack,
    output logic mem_l15_req_ack,

    output logic memOp_done,
    output logic ld_addr_misaligned6,
    output logic samo_addr_misaligned6,


	output logic bjtaken6,		//need some debug
	output logic exception,

	output logic [31:0] csr_wb,
	output logic [11:0] csr_wb_addr,
	output logic csr_we6,

	// exceptions
	//output logic pc_exc,
	output logic [31:0] cause6,
	output logic exception_pending,
	output logic mret6, sret6, uret6,

	output logic m_interrupt, s_interrupt, u_interrupt,
	// aes start signal
	output logic start_aes
    );


	// wires
	logic btaken;
	logic bjtaken4;
	logic j5;
	logic jr5;
	logic [31:0] mul_div5;
	
	logic m_op6;


	// =============================================== //
	//			Pipe 5			   //
	// =============================================== //

	logic [31:0] opaReg5;		// Operand A at ALU input
	logic [31:0] opbReg5;		// Operand B at ALU input



	logic [2:0] fnReg5;
	logic [3:0] alufnReg5;	   // alu control in exe stage will be input to alu block

	logic [31:0] alu_res5;
	logic weReg5;
	logic [4:0] rdReg5;
	logic [4:0] rs1Reg5;

	logic bneqReg5;
	logic btypeReg5;
	logic bjtakenReg5;

	logic [31:0] B_immReg5;
	logic [31:0] J_immReg5;
	logic [31:0] U_immReg5;

	logic jReg5;
	logic jrReg5;
	logic LUIReg5;
	logic auipcReg5;

	logic [3:0] mulDiv_opReg5;

	logic [31:0] pcReg5;
	logic [1:0] pcselectReg5;

	// csr
	logic [2:0]  funct3Reg5;
	logic [31:0] csr_dataReg5, csr_immReg5;
  logic [31:0] csr5;
	logic [11:0] csr_addrReg5;
	logic csr_weReg5;
	logic [31:0] csr_rd5;
	// exceptions
	logic ecallReg5, ebreakReg5;
	logic instruction_addr_misalignedReg5;
	logic illegal_instrReg5;
	logic mretReg5, sretReg5, uretReg5;
	logic illegal_csr;
	// aes inst.
	logic aes_instReg5;

	always_ff @(posedge clk, negedge nrst)
	begin
        if (!nrst)
          begin
		        opaReg5   	<= 0;
		        opbReg5   	<= 0;
		        alufnReg5 	<= 0;
		        fnReg5	 	  <= 0;

		        rdReg5	  	 <= 0;
		        rs1Reg5    <= 0;
		
		        weReg5		   <= 0;

		        B_immReg5 	<= 0;
		        J_immReg5 	<= 0;
		        U_immReg5 	<= 0;

		        bneqReg5	  <= 0;
		        btypeReg5 	<= 0;

		        jReg5 		   <= 0;
		        jrReg5 		  <= 0;
		        LUIReg5   	<= 0;
		        auipcReg5  <= 0;

		        mulDiv_opReg5	<= 0;

		        pcReg5	  	    <= 0;
		        pcselectReg5	 <=2'b0;

		        bjtakenReg5		 <= 0;
		        funct3Reg5	   <= '0;
		        csr_immReg5	  <= '0;
		        csr_dataReg5 	<= '0;
		        csr_addrReg5	 <= '0;
		        csr_weReg5	   <= 0;

		        ecallReg5	    <= 0;
		        ebreakReg5	   <= 0;
		        instruction_addr_misalignedReg5 <= 0;
		        illegal_instrReg5 <= 0;
		        mretReg5	<= 0;
		        sretReg5	<= 0;
		        uretReg5	<= 0;
            aes_instReg5 <= 0;
          end
          
        else if (exception)
          begin
            opaReg5   	<= 0;
		        opbReg5   	<= 0;
		        alufnReg5 	<= 0;
		        fnReg5	 	  <= 0;

		        rdReg5	  	 <= 0;
		        rs1Reg5    <= 0;
		
		        weReg5		   <= 0;

		        B_immReg5 	<= 0;
		        J_immReg5 	<= 0;
		        U_immReg5 	<= 0;

		        bneqReg5	  <= 0;
		        btypeReg5 	<= 0;

		        jReg5 		   <= 0;
		        jrReg5 		  <= 0;
		        LUIReg5   	<= 0;
		        auipcReg5  <= 0;

		        mulDiv_opReg5	<= 0;

		        pcReg5	  	    <= 0;
		        pcselectReg5	 <=2'b0;

		        bjtakenReg5		 <= 0;
		        funct3Reg5	   <= '0;
		        csr_immReg5	  <= '0;
		        csr_dataReg5 	<= '0;
		        csr_addrReg5	 <= '0;
		        csr_weReg5	   <= 0;

		        ecallReg5	    <= 0;
		        ebreakReg5	   <= 0;
		        instruction_addr_misalignedReg5 <= 0;
		        illegal_instrReg5 <= 0;
		        mretReg5	<= 0;
		        sretReg5	<= 0;
		        uretReg5	<= 0;
		        aes_instReg5 <= 0;
          end
          
        else
          begin


		opaReg5   	<= op_a;

		opbReg5   	<= op_b;

 		alufnReg5 	<= alu_fn4;
		fnReg5	  	<= fn4;

		rdReg5	  	<= rd4;
		rs1Reg5   <= rs1_4;
		
		weReg5	  	<= we4;

		B_immReg5 	<= B_imm4;
		J_immReg5 	<= J_imm4;
		U_immReg5 	<= U_imm4;

		bneqReg5  	<= bneq4;
		btypeReg5 	<= btype4;

		jReg5 		<= j4;
		jrReg5 		<= jr4;
		LUIReg5 	<= LUI4;
		auipcReg5 	<= auipc4;

		mulDiv_opReg5 	<= mulDiv_op4;

		pcReg5	  	<= pc4;
		pcselectReg5 	<= pcselect4;

		bjtakenReg5	<=bjtaken4;

		funct3Reg5	  <= funct3_4;
		csr_immReg5	 <= csr_imm4;
		csr_dataReg5	<= csr_data;
		csr_addrReg5	<= csr_addr4;
		csr_weReg5	  <= csr_we4;

		ecallReg5	<= ecall4;
		ebreakReg5	<= ebreak4;
		instruction_addr_misalignedReg5 <= instruction_addr_misaligned4;
		illegal_instrReg5 <= illegal_instr4;
		mretReg5	<= mret4;
		sretReg5	<= sret4;
		uretReg5	<= uret4;
		aes_instReg5 <= aes_inst4;
end
end



	csr_unit csr_1(
	.func3(funct3Reg5),
	.rs1(rs1Reg5),
	.rs1_val(opaReg5),
	.imm(csr_immReg5),
	.csr_addr(csr_addrReg5),
	.csr_reg(csr_dataReg5),
	.system(csr_weReg5),
	.current_mode(current_mode),
	.csr_new(csr5),
	.csr_old(csr_rd5),
	.illegal_csr(illegal_csr)
	);



	// =============================================== //
	//			Pipe 6			   //
	// =============================================== //


	logic [2:0] fnReg6;
	logic [31:0] alu_resReg6;

	logic [4:0] rdReg6;
	logic weReg6;

	logic [31:0] U_immReg6;
	logic [31:0] AU_immReg6;

	logic [31:0] pcReg6;
  logic [31:0] mem_out6;
	logic [2:0] fn6;
	// csr
	logic [31:0] csr_rdReg6;	// this will be written back in regfile
	logic [31:0] csrReg6;		// this will be written back in csr regfile
	logic [11:0] csr_addrReg6;	// csr address that new data will be written in
	logic csr_weReg6;

	// exceptions
	logic instruction_addr_misalignedReg6;
	logic ecallReg6, ebreakReg6;
	logic illegal_instrReg6;
	logic illegal_csrReg6;
	//logic exception;
	logic mretReg6, sretReg6, uretReg6;
	// aes inst.
	logic aes_instReg6;

	always @(posedge clk, negedge nrst)
	begin
	if (!nrst)
	  begin
		fnReg6			<= 3'b0;
    		rdReg6 	    		<= 5'b0;
		alu_resReg6 		<= 32'b0;
		weReg6 			<= 0;
		U_immReg6 	  	<= 32'b0;
    		AU_immReg6 	 	<= 32'b0;
		mul_divReg6 		<= 32'b0;
		pcReg6 			<= 32'b0;
		csr_rdReg6		<= 32'b0;
		csrReg6			<= 32'b0;
		csr_addrReg6		<= 12'b0;
		csr_weReg6 			<= 0;
		instruction_addr_misalignedReg6 <= 0;
		ecallReg6	  	<= 0;
		ebreakReg6		<= 0;
		illegal_instrReg6 	<= 0;
		illegal_csrReg6 <= 0;
		mretReg6		<= 0;
		sretReg6		<= 0;
		uretReg6		<= 0;
		aes_instReg6 <= 0;
	  end
	else
	  begin
	  if(exception)begin
	   pcReg6 		    <=  pcReg6;

	  	fnReg6 	  	  <= 3'b0;
		rdReg6 		    <= 5'b0;
		alu_resReg6 	<= 32'b0;
		weReg6 		    <= 1'b0;
		U_immReg6 	  <= 32'b0;
    		AU_immReg6 	 <= 32'b0;
		mul_divReg6 	<= 32'b0;

		csr_weReg6 		<=  0;

		csr_rdReg6	  <=  32'b0;
		csrReg6		    <=  32'b0;
		csr_addrReg6	<=  12'b0;

		instruction_addr_misalignedReg6 <= 0;
		ecallReg6	  	<=  0;
		ebreakReg6		<= 0;
		illegal_instrReg6  <= 0;
		illegal_csrReg6 <= 0;
		
		mretReg6	<= 0;
		sretReg6	<= 0;
		uretReg6	<= 0;
    aes_instReg6 <= 0;
	   end
		else begin

		    fnReg6 		    <=  fnReg5;
		    rdReg6 		    <=  rdReg5;
		    alu_resReg6 	<=  alu_res5;
		    weReg6 		    <=  weReg5;
		    U_immReg6 	  <=  U_immReg5;
   		   AU_immReg6 	 <=  U_immReg5+pcReg5 ;
    		  mul_divReg6 	<=  mul_div5;
    		  pcReg6 		    <=  pcReg5;

    		  csr_weReg6 		<=  csr_weReg5;

    		  csr_rdReg6	  <=  csr_rd5;
		    csrReg6		    <=  csr5;
		    csr_addrReg6	<=  csr_addrReg5;

		    instruction_addr_misalignedReg6 <= instruction_addr_misalignedReg5;
			ecallReg6	<=  ecallReg5;
			ebreakReg6	<= ebreakReg5;
		    illegal_instrReg6  <= illegal_instrReg5;
		    illegal_csrReg6 <= illegal_csr;
		    
		    mretReg6	<= mretReg5;
		    sretReg6	<= sretReg5;
		    uretReg6	<= uretReg5;
		    aes_instReg6 <= aes_instReg5;
		    end
	  end
	end



	  //ALU
	alu exe_alu (
	.alu_fn(alufnReg5),
	.operandA(opaReg5),
	.operandB(opbReg5),
	.result(alu_res5),
	.bneq(bneqReg5),
	.btype(btypeReg5),
	.btaken(btaken)
	);

    // branch unit
	branch_unit exe_bu (
	.pc          (pcReg5),
	.operandA    (opaReg5),
	.B_imm       (B_immReg5),
	.J_imm       (J_immReg5),
	.I_imm       (opbReg5),
	.btaken      (btaken),
	.jr          (jrReg5 && ~jr4),
	.j           (jReg5 ),
	.target      (target)
    );

    mem_wrap exe_mem_wrap(
    .clk                   (clk),
    .nrst                  (nrst),
    .mem_op4               (mem_op4),//memory operation type
    .op_a4                 (op_a),  //base address
    .op_b4                 (op_b), //src for store ops, I_imm offset for load ops
    .S_imm4                (S_imm4), //S_imm offset
	.stall_mem			   (stall_mem),
	.dmem_finished 		   (dmem_finished),

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
    .mem_out6              (mem_out6),   //memory read output
    .memOp_done            (memOp_done),
    .m_op6                 (m_op6),
    .ld_addr_misaligned6   (ld_addr_misaligned6),
    .samo_addr_misaligned6 (samo_addr_misaligned6)
);
	mul_div mul1(
	.a		(opaReg5),
	.b		(opbReg5),
	.mulDiv_op	(mulDiv_opReg5),
	.res		(mul_div5)
	);
	
	// =============================================== //
	//                AES START SIGNAL                 //
	// =============================================== //
	
	// this signal should start the aes ip enc.
	// and stall the processor untill the aes operation is done
	assign start_aes = aes_instReg6;
	 
	// =============================================== //
	//		              Exception Logic		                //
	// =============================================== //

	logic [31:0] cause            ;
	logic m_timer_conditioned     ;
	logic s_timer_conditioned     ;
  	logic u_timer_conditioned    ;
	logic m_interrupt_conditioned ;
	logic s_interrupt_conditioned ;
  	logic u_interrupt_conditioned ;

	assign m_timer_conditioned     =                                m_tie && m_timer;
	assign s_timer_conditioned     = (current_mode != 2'b11)   &&   s_tie && s_timer;
	assign m_interrupt_conditioned =                                m_eie && external_interrupt;
	assign s_interrupt_conditioned = (current_mode != 2'b11)   &&   s_eie && external_interrupt;
  	assign u_timer_conditioned     = (current_mode == 2'b00)   &&   u_tie && u_timer;
  	assign u_interrupt_conditioned = (current_mode == 2'b00)   &&   u_eie && external_interrupt;

/* EXCEPTIONS. ********************************************************************************************************/
										      /* from data mem (L/S)*/
	assign exception =  instruction_addr_misalignedReg6 || ecallReg6 || ebreakReg6 || ld_addr_misaligned6 || samo_addr_misaligned6 || m_timer_conditioned || s_interrupt_conditioned
			|| illegal_instrReg6 || illegal_csrReg6 || s_timer_conditioned || m_interrupt_conditioned||u_interrupt_conditioned||u_timer_conditioned  || mretReg6 || sretReg6 || uretReg6;

	always_comb
	  begin
    		cause[`XLEN-1] = 0;
    		cause[`XLEN-2:0] = 0;
    		if (m_interrupt_conditioned)
		  begin
    			cause[`XLEN-1] = 1;
        		cause[`XLEN-2:0] = `M_INT_EXT;
		  end
    		else if (s_interrupt_conditioned)
		  begin
        		cause[`XLEN-1] = 1;
        		cause[`XLEN-2:0] = `S_INT_EXT;
    		  end
    		else if (m_timer_conditioned)
		  begin
    			cause[`XLEN-1] = 1;
    			cause[`XLEN-2:0] = `M_INT_TIMER;
    		  end
    		else if (s_timer_conditioned)
		  begin
    			cause[`XLEN-1] = 1;
    		 	cause[`XLEN-2:0] = `S_INT_TIMER;
    		  end
		else if (u_interrupt_conditioned)
		  begin
    			cause[`XLEN-1] = 1;
        		cause[`XLEN-2:0] = `U_INT_EXT;
		  end

    		else if (u_timer_conditioned)
		  begin
    			cause[`XLEN-1] = 1;
    			cause[`XLEN-2:0] = `U_INT_TIMER;
    		  end

		else if (instruction_addr_misalignedReg6)
		  begin
    			cause[`XLEN-2:0] = `I_ADDR_MISALIGNED;
    		  end
		else if (illegal_instrReg6 || illegal_csrReg6)
		  begin
    		    	cause[`XLEN-2:0] = `I_ILLEGAL;
    		  end
		else if (ecallReg6)
		  begin
		    if (current_mode == `U)
			   cause[`XLEN-2:0] = `U_CALL;
			  else if (current_mode == `S)
			    cause[`XLEN-2:0] = `S_CALL;
			  else
			    cause[`XLEN-2:0] = `M_CALL;  
    		  end
    		else if (ebreakReg6)
		  begin
        		cause[`XLEN-2:0] = `BREAKPOINT;
    		  end
		// addr_misaligned6 will divided to load & store exceptions
    		else if (ld_addr_misaligned6)
		  begin
        		cause[`XLEN-2:0] = `L_ADDR_MISALIGNED;
    		  end
    		else if (samo_addr_misaligned6)
		  begin
        		cause[`XLEN-2:0] = `S_ADDR_MISALIGNED;
    		  end
		else
		  begin
			cause[`XLEN-1] = 0;
    			cause[`XLEN-2:0] = 0;
		  end
	  end


	// =============================================== //
	//			 Outputs		   //
	// =============================================== //
	assign fn6 = fnReg6;
	assign rd6 = rdReg6;
    /*
    --------------------------------
    | m_op6 | memOp_done |   we6   |
    --------------------------------
    |   0   |      0     |  weReg6 |
    |   0   |      1     |  weReg6 |  //though this may not seem logical, but this is the case that happens
    |   1   |      0     |    0    |
    |   1   |      1     | weReg6  |
    --------------------------------

    we6 = ((m_op6 XNOR memOp_done) AND weReg6) OR ((NOT(m_op6) XNOR memOp_done) AND weReg6)

    This is not optimal, but it works. I hate it too!!!
    */
	assign we6 = ((m_op6 ~^ memOp_done) & weReg6) | ((!m_op6 ~^ memOp_done) & weReg6);

	assign U_imm6 		= U_immReg6;
	assign AU_imm6 		= AU_immReg6;

	// to csr register file through commit stage
	assign csr_wb 		 = csrReg6;
	assign csr_wb_addr 	 = csr_addrReg6;
	assign csr_we6 		 = csr_weReg6;
	assign m_interrupt	 = m_interrupt_conditioned;
	assign s_interrupt	 = s_interrupt_conditioned;
	assign u_interrupt	 = u_interrupt_conditioned;
	assign cause6 		 = cause;
	assign exception_pending = exception;
	assign mret6		 = mretReg6;
	assign sret6		 = sretReg6;
	assign uret6		 = uretReg6;

	assign pc6 = pcReg6;

	assign bjtaken6 = btaken || j4  || jr4 ;
	assign pcselect5= btaken || jrReg5 || jReg5 ? pcselectReg5: 2'b00;
	always_comb begin
        unique case(fn6)
            0: wb_data6  = alu_resReg6;
            1: wb_data6  = pcReg6 + 4;
            2: wb_data6  = mul_divReg6;
            3: wb_data6  = U_imm6;
            4: wb_data6  = mem_out6;
            5: wb_data6  = AU_imm6;
	          6: wb_data6  = csr_rdReg6;
            default: wb_data6 = 0;
        endcase
	end
endmodule
