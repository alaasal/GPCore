module exe_stage(
    input logic clk, nrst,
    input logic we4 ,bneq4 ,btype4,
    input logic [2:0] fn4,
    input logic [4:0] rd4,			// rd address from issue stage
    input logic [3:0] alu_fn4,
    input logic [31:0] op_a, op_b,		// operands a and b from issue stage
    input logic [31:0] pc4, B_imm4, J_imm4, U_imm4 , S_imm4,
    input logic [1:0] pcselect4,
    input logic j4, jr4,LUI4,auipc4,
    
    output logic we5,
    output logic [2:0] fn5,
    output logic [31:0] alu_res5,  		// alu result in PIPE #5
    output logic [4:0] rd5,
    output logic [31:0] target,U_imm5,
    output logic [1:0] pcselect5,
    output logic j5, jr5,LUI5,auipc5,
    output logic [31:0] mem_out6,
    output logic addr_misaligned6
    );
    
    // wires 
    logic btaken;
    // registers
    logic weReg5,bneqReg5,btypeReg5;
    logic [2:0] fnReg5;
    logic [31:0] opaReg5;	   // pipe #5 from decode to execute stage (operand A at execute stage)
    logic [31:0] opbReg5;	   // pipe #5 from decode to execute stage (operand B at execute stage)
    logic [3:0] alufnReg5;	   // alu control in exe stage will be input to alu block
    logic [4:0] rdReg5;
    logic [31:0] B_immReg5, J_immReg5,U_immReg5;
    logic [31:0] pcReg5;	
    logic [1:0] pcselectReg5;
    logic jReg5, jrReg5,LUIReg5,auipcReg5;
           
    
    
    //ALU
    alu exe_alu (.alu_fn(alufnReg5), .operandA(opaReg5), .operandB(opbReg5), .result(alu_res5) , .bneq(bneqReg5), .btype(btypeReg5) , .btaken(btaken) );
    
    // branch unit
    branch_unit exe_bu (
    .pc          (pcReg5),
    .operandA    (opaReg5),
    .B_imm       (B_immReg5),
    .J_imm       (J_immReg5),
    .I_imm       (opbReg5),
    .btaken      (btaken),
    .jr          (jrReg5),
    .j           (jReg5),
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

    // pipes
    always_ff @(posedge clk, negedge nrst)
      begin
        if (!nrst)
          begin
            opaReg5   <= 0;
            opbReg5   <= 0;
            alufnReg5 <= 0;
            rdReg5	  <= 0;
            fnReg5	  <= 0;
            weReg5	  <= 0;
            bneqReg5  <= 0;
            btypeReg5 <= 0;
            B_immReg5 <= 0;
            J_immReg5 <= 0;
            U_immReg5 <= 0;
            pcReg5	  <= 0;
            pcselectReg5<=0;
            jReg5 <= 0;
            jrReg5 <= 0;
            LUIReg5   <=0;
            auipcReg5   <=0;
          end
        else
          begin
            opaReg5   <= op_a;
            opbReg5   <= op_b;	
            alufnReg5 <= alu_fn4;
            rdReg5	  <= rd4;
            fnReg5	  <= fn4;
            weReg5	  <= we4;
            bneqReg5  <= bneq4;
            btypeReg5 <= btype4;	
            B_immReg5 <= B_imm4;
            J_immReg5 <= J_imm4;
            U_immReg5 <= U_imm4;
            pcReg5	  <= pc4;
            pcselectReg5 <= pcselect4;
            jReg5 <= j4;
            jrReg5 <= jr4;
            LUIReg5 <= LUI4;
            auipcReg5 <= auipc4;
          end
      end

    // output
    assign rd5 = rdReg5;
    assign fn5 = fnReg5;
    assign we5 = weReg5;
    assign pcselect5=pcselectReg5;
    assign U_imm5 = U_immReg5;

endmodule

