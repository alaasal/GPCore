
//this testbench is designed to test frontend  
//in this test bench we instantiate 2 modules frontend_stage module  and debug module
`timescale 10ns/10ns 
module tb_front_end; 


reg clk;            //core clock
reg clk_debug;      //debug clock
reg [1:0]PCSEL;
reg [31:0] b_target;
reg nrst;           //reset signal

reg DEBUG_SIG ;
reg [31:0] DEBUG_addr ;
reg [31:0] DEBUG_instr;

reg clk_cc ,clk_debug_cc ; // additional signals to help control clk and clk_debug

wire [31:0] pc2;
wire [31:0] instr2;
wire [31:0] pc;
	
//instantiation of DUTs
frontend_stage  dut_1  (.clk(clk),.nrst(nrst),.PCSEL(PCSEL),.b_target(b_target),.pc2(pc2),.instr2(instr2),.pc(pc),.DEBUG_SIG(DEBUG_SIG),.DEBUG_addr(DEBUG_addr),.DEBUG_instr(DEBUG_instr),.clk_debug(clk_debug));
debug           dut_2  (.clk(clk_debug), .nrst(nrst), .DEBUG_SIG(DEBUG_SIG), .DEBUG_addr(DEBUG_addr),.DEBUG_instr(DEBUG_instr), .START(START));

//here we simulate control of clk and clk_debug , that control is done in Top module
assign clk = clk_cc & START;
assign clk_debug= clk_debug_cc & ~(START);

//clocks  generation
initial begin 
    clk_cc = 0;
    clk_debug_cc = 0;  
 end 
 always begin 
 #10 clk_cc = ~clk_cc;
 #10 clk_debug_cc = ~clk_debug_cc;
  end
 

//stimulus generation 
 initial begin 
	   nrst = 0;
#25  nrst = 1;
     b_target = 32'h3;  
     PCSEL = 2'b 00;
#400 PCSEL = 2'b 01;
#50  PCSEL = 2'b 10;
#50  PCSEL = 2'b 01;
#50 PCSEL = 2'b 00;
  
   end 
endmodule

