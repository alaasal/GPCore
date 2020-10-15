class packet; // used for randomization of variables
  rand bit [31:0] instr2_rand;   
  rand bit [31:0] pc2_rand;
endclass


module tb_instdec_stage;
reg  clk, nrst; // input signl
reg  [31:0] instr2;  // input from frontend stage (inst mem)
reg  [31:0] pc2;		  // input from frontend stage (pc)


wire  we3  , bneq3 , btype3 ,jr3, j3, LUI3, auipc3; // control signals
wire [2:0]   fn3 ;
wire [4:0]   rs1, rs2;		  // op registers addresses
wire [4:0]   rd3;  		  // dest address
wire [4:0]   shamt;		  // shift amount I_imm
wire [31:0]  I_imm3;		  // I_immediate
wire [31:0]  B_imm3;		  // B_immediate
wire [31:0]  J_imm3;
wire [1:0]   B_SEL3;
wire [31:0]  S_imm3;	 
wire [3:0]   alu_fn3;
wire [31:0]  pc3;
wire [31:0]  U_imm3;
wire [1:0]   pcselect3;
wire [3:0]   mem_op3;
wire [2:0]   m_op3;
// instantiate device under test
 instdec_stage dut(.clk(clk), .nrst(nrst), .instr2(instr2), .pc2(pc2), .we3(we3), .fn3(fn3), .bneq3(bneq3), .btype3(btype3), .jr3( jr3), .j3(j3), .LUI3(LUI3), .auipc3(auipc3), .rs1(rs1), .rs2(rs2), .rd3(rd3) , .shamt(shamt) , .I_imm3(I_imm3) , .B_imm3(B_imm3) , .B_SEL3(B_SEL3) , .J_imm3( J_imm3), .alu_fn3(alu_fn3) , .pc3(pc3) , .U_imm3(U_imm3), .pcselect3(pcselect3) , .mem_op3(mem_op3) , .S_imm3(S_imm3), .m_op3(m_op3)  );

// generate clock
initial begin 
    clk =0; 
 end 
 always
 #10 clk = ~clk;

  initial begin
    packet pkt;
    pkt = new(); 
    nrst = 0;
    #25  nrst = 1;
    repeat(10)begin
 	pkt.randomize();
    	instr2 = pkt.instr2_rand;  
     	pc2 = pkt.pc2_rand;              
    end
  end 
endmodule
