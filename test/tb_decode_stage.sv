module tb_instdec_stage;
reg clk, nrst; // input signl
reg  [31:0] instr2;  // input from frontend stage (inst mem)
reg  [31:0] pc2;		  // input from frontend stage (pc)

wire we3 , fn3 , bneq3 , btype3; // control signals
wire [4:0] rs1, rs2;		  // op registers addresses
wire [4:0] rd3;  		  // dest address
wire [4:0] shamt;		  // shift amount I_imm
wire [31:0] I_imm3;		  // I_immediate
wire [31:0] B_imm3;		  // B_immediate
wire [1:0] B_SEL3;	 
wire [3:0] alu_fn3;
wire [31:0] pc3;
wire [1:0] pcselect3;
// instantiate device under test
 instdec_stage dut(.clk(clk), .nrst(nrst), .instr2(instr2), .pc2(pc2), .we3(we3), .fn3(fn3), .bneq3(bneq3), .btype3(btype3), .rs1(rs1), .rs2(rs2), .rd3(rd3) , .shamt(shamt) , .I_imm3(I_imm3) , .B_imm3(B_imm3) , .B_SEL3(B_SEL3) , .alu_fn3(alu_fn3) , .pc3(pc3) , .pcselect3(pcselect3)  );

// generate clock
initial begin 
    clk =0; 
 end 
 always
 #10 clk = ~clk;

 initial begin 
 nrst = 1;
	#50 instr2 <= 32'h F0CCF0E2;        //rs1=11001, rs2=01100, rd3=00001, shamt= 01100
        pc2 <= 32'h F0CCF0E2;
 nrst = 0;
	#50 instr2 <= 32'h F0CCF0E2;       
        pc2 <= 32'h F0CCF0E2;
     end 
  
 
endmodule
