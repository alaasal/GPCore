module instdec_stage(
    input logic clk, nrst,stall,
    input logic  [31:0] instr2,		  // input from frontend stage (inst mem)
    input logic  [31:0] pc2,		  // input from frontend stage (pc)

    output logic we3 , bneq3 , btype3, jr3, j3,LUI3,auipc3,  // control signals
    output logic [2:0] fn3,
    output logic [4:0] rs1, rs2,		  // op registers addresses
    output logic [4:0] rd3,  		  // dest address
    output logic [4:0] shamt,		  // shift amount I_imm
    output logic [31:0] I_imm3,		  // I_immediate
    output logic [31:0] B_imm3,		  // B_immediate
    output logic [31:0] J_imm3,
    output logic [31:0] U_imm3,
    output logic [31:0] S_imm3,
    output logic [1:0] B_SEL3,	 
    output logic [3:0] alu_fn3,
    output logic [31:0] pc3,
    output logic [1:0] pcselect3,
    output logic [3:0] mem_op3,
    output logic [2:0] m_op3,
    output logic [6:0]opcode3
    );

    // wires
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic instr_30;
    
    // registers
    logic [31:0] instrReg3;	// pipe #3 from inst mem to decode stage
    logic [31:0] pcReg3;	// pipe #3 from inst mem to decode stage
  	logic [1:0] stallnum;
    
    // PIPE
   /*always_ff @(posedge clk, negedge nrst)
      begin
        if (!nrst)
            begin
            instrReg3 <= 0;
            pcReg3<=0;
            end
        else if(!stall)
            begin
            instrReg3 <= instr2;
            pcReg3<=pc2;
            end
         else begin 
            instrReg3<=instrReg3;
            pcReg3<=pcReg3;
       end 
      end*/
always_ff @(posedge clk , negedge nrst)
      begin
        if (!nrst)
          begin
            instrReg3 <= 0;
            pcReg3<=0;
	stallnum 		<= 0;
          end
         else if (stall && !((stallnum[1]) &&(stallnum[0])))
          begin
                 instrReg3<=instrReg3;
            pcReg3<=pcReg3;

		
          end
  else if ((stallnum[1]) &&(stallnum[0]) )begin 

            instrReg3 <= instr2;
            pcReg3<=pc2;
	stallnum <=0;
end 
else begin 
            instrReg3 <= instr2;
            pcReg3<=pc2;
end 
      end

always_ff@(posedge clk)
begin 
        if (stall)
          begin
         stallnum<=stallnum+1;

		
          end
  else begin 


	
end 
end

    // output
    // decoding instructions
    assign opcode   = instrReg3[6:0];
    assign funct3   = instrReg3[14:12];
    assign funct7   = instrReg3[31:25];
    assign instr_30 = instrReg3[30];
    assign rs1      = instrReg3[19:15];
    assign rs2      = instrReg3[24:20];
    assign rd3      = instrReg3[11:7];
    assign shamt    = instrReg3[24:20];
    assign I_imm3   = 32'(signed'(instrReg3[31:20]));  // sign extended I_immediate to 32-bit
    assign B_imm3	  = 32'(signed'({instrReg3[31], instrReg3[7], instrReg3[30:25], instrReg3[11:8], 1'b0 })); //sign extending b_immediate to 32-bit
    assign J_imm3	  = 32'(signed'({instrReg3[31], instrReg3[19:12], instrReg3[20], instrReg3[30:21], 1'b0}));
    assign U_imm3   = 32'(signed'({instrReg3[31:12] , {12'b0}}));
    assign S_imm3   = 32'(signed'({instrReg3[31:25], instrReg3[11:7]}));
    assign pc3 	= pcReg3;
    assign opcode3 = opcode;
    
    // instantiate controller
    instr_decoder c1 (
    .op          (opcode),
    .funct3      (funct3),
    .funct7      (funct7),
    .instr_30    (instr_30),	// bit 30 in the instruction
    .stall       (stall),
    .pcselect    (pcselect3),	// select pc source
    .we          (we3),			  // regfile write enable
    .B_SEL       (B_SEL3),		// select op b
    .alu_fn      (alu_fn3),		// select alu operation
    .fn          (fn3),				// select result to be written back in regfile
    .bneq        (bneq3),
    .btype       (btype3),		// to alu beq ~ bneq  
    .j           (j3),
    .jr          (jr3),
    .mem_op      (mem_op3),
    .LUI         (LUI3),
    .auipc       (auipc3),
    .m_op        (m_op3)      //m extension opcode
    );
    
endmodule
