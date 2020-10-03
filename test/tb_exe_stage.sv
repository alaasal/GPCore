module tb_exe_stage;
reg clk, nrst; 
reg fn4, we4 ,bneq4 ,btype4;
reg [4:0] rd4;
reg  [3:0] alu_fn4;
reg  [31:0] op_a, op_b;
reg [31:0] pc4,B_imm4;
reg [1:0] pcselect4;
reg btaken;

wire fn5, we5;
wire [31:0] alu_res5;
wire [4:0] rd5;
wire [31:0] b_target;
wire [1:0] pcselect5;

// instantiate device under test
 exe_stage dut(.clk(clk), .nrst(nrst), .fn4(fn4), .we4(we4), .bneq4(bneq4), .btype4(btype4), .rd4(rd4), .alu_fn4(alu_fn4), .op_a(op_a), .op_b(op_b), .pc4(pc4) , .B_imm4(B_imm4) , .pcselect4(pcselet4) , .fn5(fn5) , .we5(we5) , .alu_res5(alu_res5) , .rd5(rd5) , .b_target(b_target) , .pcselect5(pcselect5) );

// generate clock
initial begin 
    clk =0; 
 end 
 always
 #10 clk = ~clk;

 initial begin 
	 
       nrst = 1;
 	#20 fn4=0; we4=0; bneq4=0; btype4=1;
	rd4=5'b 00110;
	alu_fn4=4'b 0111; //and
	op_a=32'h 4fff0043; op_b=32'h 784455ff;
	pc4=32'h 33333333; B_imm4=32'h 0f0f3333;
	pcselect4= 10;
       nrst = 0;
 	#40 fn4=0; we4=0; bneq4=0; btype4=1;
	rd4=5'b 00110;
	alu_fn4=4'b 0111; //and
	op_a=32'h 4fff0043; op_b=32'h 784455ff;
	pc4=32'h 33333333; B_imm4=32'h 0f0f3333;
	pcselect4= 10;
      
      
     end 
  
 
endmodule
