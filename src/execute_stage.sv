`include "define.sv"
module exe_stage(
	input logic clk, nrst,

	input logic [31:0] op_a,
 	input logic [31:0] op_b,
	input logic [4:0] rd4,			// rd address from issue stage

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
	input logic [2:0] mulDiv_op4,

	input logic [31:0] pc4,
	input logic [1:0] pcselect4,

	// csr
	input logic [2:0] funct3_4,
	input logic [31:0] csr_data, csr_imm4,
	input logic [11:0] csr_addr4,

	// exceptions 
	input logic instruction_addr_misaligned4,
	input logic ecall4,

	output logic [31:0] wb_data6,
	output logic we6,


	output logic [4:0] rd6,

	output logic [31:0] U_imm6,
	output logic [31:0] AU_imm6 ,

	output logic [31:0] mem_out6,
	output logic addr_misaligned6,

	output logic [31:0] mul_divReg6,

	output logic [31:0] target,
	output logic [31:0] pc6,
	output logic [1:0] pcselect5,

	output logic bjtaken6,		//need some debug

	output logic [31:0] csr_wb,
	output logic [11:0] csr_wb_addr,

	// exceptions
	output logic pc_exc,
	output logic [31:0] m_cause,
	output logic exception_pending
    );

	// wires
	logic btaken;
	logic bjtaken4;
	logic j5;
	logic jr5;
	logic [31:0] mul_div5;
	
	
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

	logic [2:0] mulDiv_opReg5;

	logic [31:0] pcReg5;
	logic [1:0] pcselectReg5;
	// csr
	logic [2:0]  funct3Reg5;
	logic [31:0] csr_dataReg5, csr_immReg5;
	logic [11:0] csr_addrReg5;
	// exceptions
	logic ecallReg5;
	logic instruction_addr_misalignedReg5;

	always_ff @(posedge clk, negedge nrst)
	begin
        if (!nrst)
          begin
		opaReg5   	<= 0;
		opbReg5   	<= 0;

		alufnReg5 	<= 0;
		fnReg5	 	<= 0;

		rdReg5	  	<= 0;
		weReg5		<= 0;

		B_immReg5 	<= 0;
		J_immReg5 	<= 0;
		U_immReg5 	<= 0;

		bneqReg5	<= 0;
		btypeReg5 	<= 0;

		jReg5 		<= 0;
		jrReg5 		<= 0;
		LUIReg5   	<=0;
		auipcReg5   	<=0;

		mulDiv_opReg5	<= 0;

		pcReg5	  	<= 0;
		pcselectReg5	<=2'b0;

		bjtakenReg5	<= 0;

		funct3Reg5	<= '0;
		csr_immReg5	<= '0;
		csr_dataReg5	<= '0;
		csr_addrReg5	<= '0;

		ecallReg5	<= 0;
		instruction_addr_misalignedReg5 <= 0;
          end
        else
          begin
		opaReg5   	<= op_a;
		opbReg5   	<= op_b;

 		alufnReg5 	<= alu_fn4;
		fnReg5	  	<= fn4;

		rdReg5	  	<= rd4;
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

		funct3Reg5	<= funct3_4;
		csr_immReg5	<= csr_imm4;
		csr_dataReg5	<= csr_data;
		csr_addrReg5	<= csr_addr4;

		ecallReg5	<= ecall4;
		instruction_addr_misalignedReg5 <= instruction_addr_misaligned4;
          end
      end


	  //ALU
	alu exe_alu (
	.alu_fn(alufnReg5 ),
	.operandA(opaReg5 ),
	.operandB(opbReg5 ),
	.result(alu_res5) ,
	.bneq(bneqReg5),
	.btype(btypeReg5) ,
	.btaken(btaken)
	);

    // branch unit
	branch_unit exe_bu (
	.pc          (pc4),
	.operandA    (op_a),
	.B_imm       (B_imm4),
	.J_imm       (J_imm4),
	.I_imm       (op_b),
	.btaken      (btaken),
	.jr          (jr4),
	.j           (j4),
	.target      (target)
    );

	mem_wrap dmem_wrap (
	.clk                 (clk),
	.nrst                (nrst),
	.mem_op4             (mem_op4), //memory operation type
	.op_a4               (op_a),   //base address
	.op_b4               (op_b),   //src for store ops, I_imm offset for load ops
	.S_imm4              (S_imm4),  //S_imm offset
	.mem_out6            (mem_out6),
	.addr_misaligned6    (addr_misaligned6)
	);

	mul_div mul1(
	.a		(opaReg5),
	.b		(opbReg5),
	.mulDiv_op	(mulDiv_opReg5),
	.res		(mul_div5)
	);

	csr csr_unit(
	.func3(funct3Reg5),
	.rs1(op_a),
	.imm(csr_immReg5),
	.csr_reg(csr_dataReg5),
	.current_mode(),
	.csr_new(csr5),
	.csr_old(csr_rd5)
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

	logic [2:0] fn6;
	// csr
	logic [31:0] csr_rdReg6;	// this will be written back in regfile
	logic [31:0] csrReg6;		// this will be written back in csr regfile
	logic [11:0] csr_addrReg6;	// csr address that new data will be written in
	
	// exceptions
	logic instruction_addr_misalignedReg6;
	logic ecallReg6;
	logic exception;
	
	// kill logic registers
	 logic [2:0]killnum;
	 logic kill;

	always @(posedge clk)
	begin
	if (!nrst)
	  begin
		fnReg6 		    <= 3'b0;
    rdReg6 	    	<= 5'b0;
		alu_resReg6 	<= 32'b0;
		weReg6 		    <= 0;
		U_immReg6 	  <= 32'b0;
    AU_immReg6 	 <= 32'b0;
		mul_divReg6 	<= 32'b0;
		pcReg6 		    <= 32'b0;
		csr_rdReg6	  <= 32'b0;
		csrReg6		    <= 32'b0;
		csr_addrReg6	<= 12'b0;
		instruction_addr_misalignedReg6 <= 0;
		ecallReg6	   <= 0;
		killnum      <= 0;
		kill         <= 0;
	  end
	else
	  begin
		fnReg6 		    <=  fnReg5;
		rdReg6 		    <=  rdReg5;
		alu_resReg6 	<=  alu_res5;
		weReg6 		    <=  weReg5;
		U_immReg6 	  <=  U_immReg5;
    AU_immReg6 	 <=  U_immReg5+pcReg5 ;
    mul_divReg6 	<=  mul_div5;
		pcReg6 		    <=  pcReg5;
		csr_rdReg6	  <=  csr_rd5;
		csrReg6		    <=  csr5;
		csr_addrReg6	<=  csr_addrReg5;
		instruction_addr_misalignedReg6 <= instruction_addr_misalignedReg5;
		ecallReg6	   <=  ecallReg5;
	  if(exception)begin
	  kill <=1;
	    
	  fnReg6 	  	  <= 3'b0;
		rdReg6 		    <= 5'b0;
		alu_resReg6 	<= 32'b0;
		weReg6 		    <= 1'b0;
		U_immReg6 	  <= 32'b0;
    AU_immReg6 	 <= 32'b0;
		mul_divReg6 	<= 32'b0;
		
		csr_rdReg6	  <= 32'b0;
		csrReg6		    <= 32'b0;
		csr_addrReg6	<= 12'b0;;
		instruction_addr_misalignedReg6 <= 0;
		ecallReg6	   <= 0;
	    end
		else if(kill)begin
		fnReg6 	  	  <= 3'b0;
		rdReg6 		    <= 5'b0;
		alu_resReg6 	<= 32'b0;
		weReg6 		    <= 1'b0;
		U_immReg6 	  <= 32'b0;
    AU_immReg6 	 <= 32'b0;
		mul_divReg6 	<= 32'b0;
		
		csr_rdReg6	  <= 32'b0;
		csrReg6		    <= 32'b0;
		csr_addrReg6	<= 12'b0;;
		instruction_addr_misalignedReg6 <= 0;
		ecallReg6   	<= 0;
		if (killnum>4)begin
		  kill    <=  1'b0;
		  killnum <=  3'b0;
		    end
		 else begin
		   kill    <=  1'b1;
		   killnum <=  killnum+1;
		     end
		  end
	  end
	end
	// =============================================== //
	//		  Exception Logic		   //
	// =============================================== //

	logic [31:0] mcause;
	assign exception = instruction_addr_misalignedReg6 || ecallReg6 || addr_misaligned6;
	assign mcause[31] = ~(instruction_addr_misalignedReg6 || ecallReg6 || addr_misaligned6);

	always_comb
	  begin
		// here will be a mux to check on the current mode and then set the cause register
		// currently only M-mode
		if (instruction_addr_misalignedReg6)
			mcause[30:0] = '0;
		else if (ecallReg6)
		  begin
			mcause[30:0] = 4'b1011;
		  end
		else // address misaligned
			// this will be edited for load and store misaligned
			mcause[30:0] = 4'b0100; // load exception

	  end


	// =============================================== //
	//			 Outputs		   //
	// =============================================== //
	assign fn6 = fnReg6;
	assign rd6 = rdReg6;
	assign we6 = weReg6;

	assign U_imm6 		= U_immReg6;
	assign AU_imm6 		= AU_immReg6;

	assign bjtaken6 = btaken | jr4 |j4;
	assign pcselect5=pcselect4;

	// to csr register file through commit stage
	assign csr_wb = csrReg6;
	assign csr_wb_addr = csr_addrReg6;
	assign pc_exc = pcReg6;
	assign m_cause = mcause;
	assign exception_pending = exception;

	always_comb begin
        unique case(fn6)
            0: wb_data6  = alu_resReg6;
            1: wb_data6  = pcReg6 + 1;
            2: wb_data6  = mul_divReg6;
            3: wb_data6  = U_imm6;
            4: wb_data6  = mem_out6;
            5: wb_data6  = AU_imm6;
	    6: wb_data6  = csr_rdReg6;
            default: wb_data6 = 0;
        endcase
	end
endmodule
