module issue_stage (
    input logic clk, nrst,
    input logic we6,			// we from commit stage pipe #6
    input logic we3, bneq3, btype3,	// we enable for regfile & fn for result selection (from pipe #3)
    input logic [3:0] fn3,
    input logic [4:0] rdaddr6,		// destenation address from commit stage to regfile
    input logic [1:0] B_SEL3, 		// B_SEL for op_b or I_immediates
    input logic [3:0] alu_fn3,		// alu control from decode stage
    input logic [31:0] wb6,			// data to be written in regfile
    input logic [4:0] rs1, rs2,		// addresses of operands (to regfile)	
    input logic [4:0] rd3,			// rd address will be pipelined to commit stage
    input logic [4:0] shamt,		
    input logic [31:0] I_imm3, B_imm3, J_imm3,U_imm3, S_imm3,	// immediates sign extended
    input logic [31:0] pc3,
    input logic [1:0] pcselect3,
    input logic j3, jr3,LUI3,auipc3,
    input logic [3:0] mem_op3,

    output logic we4,bneq4,btype4,	// function selection ctrl in issue stage and write enable
    output logic [3:0] fn4,
    output logic [1:0] pcselect4,
    output logic [31:0] op_a, op_b,		// operands A & B output from regfile in PIPE #4 (to exe stage)
    output logic [4:0] rd4,
    output logic [3:0] alu_fn4,		// alu control in issue stage
    output logic [31:0] pc4,B_imm4, J_imm4, S_imm4,U_imm4,
    output logic j4, jr4,LUI4,auipc4,
    output logic [3:0] mem_op4
    );

    // registers pipe #4
    logic [4:0] rdReg4;
    logic [4:0] shamtReg4;
    logic [31:0] I_immdReg4, B_immdReg4, J_immReg4, S_immReg4,U_immReg4;
    logic [1:0] BSELReg4;
    logic [3:0] alufnReg4;	
    logic [31:0] pcReg4;	
    logic weReg4,bneqReg4,btypeReg4;
    logic [2:0] fnReg4;
    logic [1:0] pcselectReg4;
    logic jReg4, jrReg4,LUIReg4,auipcReg4;
    logic [3:0] mem_opReg4;

    // wires
    logic [31:0] operand_a, operand_b;   	   // operands value output from the register file
    
    // PIPE
    always_ff @(posedge clk, negedge nrst)
      begin
        if (!nrst)
          begin
            rdReg4		<= 0;
            shamtReg4 	<= 0;
            I_immdReg4	<= 0;
            B_immdReg4	<= 0;    
            U_immReg4   <= 0;

            J_immReg4	<= 0;
            S_immReg4  <= 0;
            BSELReg4	<= 0;
            alufnReg4	<= 0;
            fnReg4		<= 0;
            weReg4		<= 0;
            pcReg4		<= 0;
            bneqReg4	<= 0;	
            btypeReg4	<= 0;
            pcselectReg4	<= 0;
            jReg4       <= 0;
            jrReg4      <= 0;           
            LUIReg4     <= 0;
            auipcReg4   <= 0;

            mem_opReg4 <= 0;
          end
        else
          begin
            rdReg4      <= rd3;
            shamtReg4	<= shamt;
            I_immdReg4	<= I_imm3;
            B_immdReg4	<= B_imm3;
            J_immReg4	<= J_imm3;
            U_immReg4   <= U_imm3;
            S_immReg4   <= S_imm3;
            BSELReg4	<= B_SEL3;
            // pass alu, fn & we control signals through the pipe form decode to issue stage
            alufnReg4	<= alu_fn3;
            fnReg4		<= fn3;
            weReg4		<= we3;
            pcReg4		<= pc3;		// passing pc to exe 
            bneqReg4	<= bneq3;
            btypeReg4	<= btype3;
            pcselectReg4	<= pcselect3;
            jReg4 <= j3;
            jrReg4 <= jr3;
            LUIReg4     <= LUI3;
            auipcReg4   <= auipc3;

            mem_opReg4 <= mem_op3;
          end
      end
    
    // register file
    regfile reg1 (.clk(clk), .clrn(nrst), .we(we6), .write_addr(rdaddr6), .source_a(rs1), .source_b(rs2), .result(wb6),
            .op_a(operand_a), .op_b(operand_b));

    // assign op_a and op_b outputs
    assign op_a = operand_a;

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

    // output
    assign alu_fn4	= alufnReg4;
    assign rd4	= rdReg4;
    assign fn4 	= fnReg4;
    assign we4 	= weReg4;
    assign pc4	= pcReg4;
    assign bneq4	= bneqReg4;
    assign btype4	= btypeReg4;
    assign B_imm4	= B_immdReg4;
    assign J_imm4	= J_immReg4;
    assign U_imm4       = U_immReg4;
    assign S_imm4 = S_immReg4;
    assign pcselect4= pcselectReg4;
    assign j4 = jReg4;
    assign jr4 = jrReg4;
    assign LUI4 = LUIReg4;
    assign auipc4 = auipcReg4;
    assign mem_op4 = mem_opReg4;
 
endmodule

