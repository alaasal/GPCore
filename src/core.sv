module core(
    input logic clk, nrst,

    input logic DEBUG_SIG,				//DEBUG Signals from debug module to load a program
    input logic [31:0] DEBUG_addr,
    input logic [31:0] DEBUG_instr,
    input logic clk_debug
    );

    // wires
    logic [31:0] pc,pc2,pc3,pc4;         // wires conneting pc to exe  
    logic [31:0] instr2;   	   // output wire of IF stage
    logic [31:0] opa, opb;     // operands value output from issue stage
    logic [4:0] rs1, rs2;
    logic [31:0] I_imm3,B_imm3;
    logic [31:0] B_imm4;
    logic btype3,btype4,bneq3,bneq4;
    logic [31:0] target;
    logic [4:0] rd3, rd4, rd5, rd6;  //(rd3 connect between output of pipe #3 and and input of pipe #4)
    logic [4:0] shamt;
    //logic we3, we4, we5, we6;
    //logic fn3, fn4, fn5;
    logic [1:0] pcselect3,pcselect4,pcselect5;	// pcselect output from pipe 3 to pipe 1
    logic [1:0] B_SEL3;
    logic [3:0] alu_fn3, alu_fn4;
    logic [31:0] alu_result5;   // alu result output from exe to commit
    logic [31:0] wb6;	   // data output from commit stage to regfile to be written
    
    // instantiating stages (7 pipelines)
    frontend_stage frontend(
    .clk            (clk),
    .nrst           (nrst),
    .PCSEL          (PCSEL),	// pc select control signal
    .target         (target),
    .pc2            (pc2),		// pc at instruction mem pipe #2
    .instr2         (instr2),	// instruction output from inst memory (to decode stage)
    .pc             (pc),		//Just for testing not an actual output, program counter PIPE #1
    .DEBUG_SIG      (DEBUG_SIG),//DEBUG Signals from debug module to load a program
    .DEBUG_addr     (DEBUG_addr),
    .DEBUG_instr    (DEBUG_instr),
    .clk_debug      (clk_debug)
    );

    instdec_stage instdec (
    .clk          (clk),
    .nrst         (nrst),
    .instr2       (instr2),	// input from frontend stage (inst mem)
    .pc2          (pc2),	// input from frontend stage (pc)
    .we3          (we3),
    .fn3          (fn3),
    .bneq3        (bneq3),
    .btype3       (btype3),
    .jr3          (jr3),
    .j3           (j3),		// control signals
    .rs1          (rs1),
    .rs2          (rs2),	// op registers addresses
    .rd3          (rd3),	// dest address
    .shamt        (shamt),	// shift amount I_imm
    .I_imm3       (I_imm3),	// I_immediate
    .B_imm3       (B_imm3),	// B_immediate
    .J_imm3       (J_imm3),
    .B_SEL3       (B_SEL3),
    .alu_fn3      (alu_fn3),
    .pc3          (pc3),
    .pcselect3    (pcselect3)
    );

    issue_stage issue (
    .clk          (clk),
    .nrst         (nrst),
    .we6          (we6),		// we from commit stage pipe #6
    .we3          (we3),
    .fn3          (fn3),
    .bneq3        (bneq3),
    .btype3       (btype3),		// we enable for regfile & fn for result selection (from pipe #3)
    .rdaddr6      (rdaddr6),	// destenation address from commit stage to regfile
    .B_SEL3       (B_SEL3),		// B_SEL for op_b or I_immediates
    .alu_fn3      (alu_fn3),	// alu control from decode stage
    .wb6          (wb6),		// data to be written in regfile
    .rs1          (rs1),
    .rs2          (rs2),		// addresses of operands (to regfile)	
    .rd3          (rd3),		// rd address will be pipelined to commit stage
    .shamt        (shamt),
    .I_imm3       (I_imm3),
    .B_imm3       (B_imm3),
    .J_imm3       (J_imm3),		// immediates sign extended
    .pc3          (pc3),
    .pcselect3    (pcselect3),
    .j3           (j3),
    .jr3          (jr3),
    .fn4          (fn4),
    .we4          (we4),
    .bneq4        (bneq4),
    .btype4       (btype4),		// function selection ctrl in issue stage and write enable
    .pcselect4    (pcselect4),
    .op_a         (op_a),
    .op_b         (op_b),		// operands A & B output from regfile in PIPE #4 (to exe stage)
    .rd4          (rd4),
    .alu_fn4      (alu_fn4),	// alu control in issue stage
    .pc4          (pc4),
    .B_imm4       (B_imm4),
    .J_imm4       (J_imm4),
    .j4           (j4),
    .jr4          (jr4)
    );

    exe_stage execute (
    .clk          (clk),
    .nrst         (nrst),
    .fn4          (fn4),
    .we4          (we4),
    .bneq4        (bneq4),
    .btype4       (btype4),
    .rd4          (rd4),		// rd address from issue stage
    .alu_fn4      (alu_fn4),
    .op_a         (op_a),
    .op_b         (op_b),		// operands a and b from issue stage
    .pc4          (pc4),
    .B_imm4       (B_imm4),
    .pcselect4    (pcselect4),
    .j4           (j4),
    .jr4          (jr4),
    .fn5          (fn5),
    .we5          (we5),
    .alu_res5     (alu_res5),	// alu result in PIPE #5
    .rd5          (rd5),
    .target       (target),
    .j5           (j5),
    .jr5          (jr5)
    );

    //TODO: ADD FUNCTION ARBITER
    commit_stage commit(
    .clk         (clk),
    .nrst        (nrst),
    .we5         (we5),
    .rd5         (rd5),
    .result5     (alu_result5),	// input result from mem to commit stage
    .rd6         (rd6),
    .wb_data6    (wb6),	// final output that will be written back in register file PIPE #6
    .we6         (we6)
    );
    
endmodule
