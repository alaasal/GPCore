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
    
	output logic [31:0] wb_data6,
	output logic we6,

	
	output logic [4:0] rd6,
	
	output logic [31:0] U_imm6,
	output logic [31:0] AU_imm6 ,
	output logic [31:0] mul_divReg6,
	
	output logic [31:0] target,
	output logic [31:0] pc6,
	output logic [1:0] pcselect5,

    //OpenPiton Request
	output logic [5:0] core_l15_rqtype, 
	output logic [2:0] core_l15_size,
	output logic [31:0] core_l15_address,
	output logic [31:0] core_l15_data,
    output logic core_l15_val,

	//OpenPiton Response
	input logic [31:0] l15_core_data_0,
	input logic [3:0] l15_core_returntype,
    
    input logic l15_core_val,
    input logic l15_core_ack,
	input logic l15_core_header_ack,
	
	output logic bjtaken6		//need some debug
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
		
		bjtakenReg5		<= 0;
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
		
		bjtakenReg5		<= bjtaken4;
          end
      end   
    
    

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
    logic ld_addr_misaligned6;
    logic samo_addr_misaligned6;
   
	
	logic [2:0] fn6;
	

 
	always @(posedge clk)
	begin
	if (!nrst)
	  begin		
		fnReg6 		<= 3'b0;

		rdReg6 		<= 5'b0;
		alu_resReg6 	<= 32'b0;
		weReg6 		<= 0;
		
		U_immReg6 	<= 32'b0;
                AU_immReg6 	<= 32'b0;
			
		mul_divReg6 	<= 32'b0;

		pcReg6 		<= 32'b0;
	  end
	else
	  begin
		fnReg6 		<= fnReg5;

		rdReg6 		<= rdReg5;	
		alu_resReg6 	<= alu_res5;
		weReg6 		<= weReg5;

		U_immReg6 	<= U_immReg5;
                AU_immReg6 	<= U_immReg5+pcReg5 ;
		
		mul_divReg6 	<= mul_div5;

		pcReg6 		<= pcReg5;
		
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

    mem_wrap exe_mem_wrap(
    .clk                   (clk),
    .nrst                  (nrst),
    .mem_op4               (mem_op4),//memory operation type
    .op_a4                 (op_a4),  //base address
    .op_b4                 (op_b4), //src for store ops, I_imm offset for load ops
    .S_imm4                (S_imm4), //S_imm offset

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
	//			 Outputs		   //
	// =============================================== //
	assign fn6 = fnReg6;
	assign rd6 = rdReg6;
	assign we6 = weReg6;
	
	assign U_imm6 		= U_immReg6;
	assign AU_imm6 		= AU_immReg6;
	
	assign bjtaken6 = btaken | jr4 |j4;
	assign pcselect5=pcselect4;
	always_comb begin
        unique case(fn6)
            0: wb_data6  = alu_resReg6;
            1: wb_data6  = pcReg6 + 1;
            2: wb_data6  = mul_divReg6;
            3: wb_data6  = U_imm6;
            4: wb_data6  = mem_out6;
            5: wb_data6  = AU_imm6 ;
            default: wb_data6 = 0;
        endcase
	end
endmodule

