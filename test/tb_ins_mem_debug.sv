
//this testbench is designed to test instruction memory writes 
//in this test bench we instantiate 2 modules instr_mem module -instruction memory- and debug module

module tb_mem_debug; 

reg clk;            //core clock
reg clk_debug;      //debug clock
reg nrst;           //reset signal
reg [31:0] addr;    //input address to instruction memory
reg clk_cc ,clk_debug_cc ; // additional signals to help control clk and clk_debug

wire DEBUG_SIG, START; // output of debug module and input to instr_mem module
wire [31:0] DEBUG_addr, DEBUG_instr; // output of debug module and input to instr_mem module
wire [31:0]instr; // output of instr_mem module


//instantiation of DUTs
debug dut_1 (.clk(clk_debug), .nrst(nrst), .DEBUG_SIG(DEBUG_SIG), .DEBUG_addr(DEBUG_addr),.DEBUG_instr(DEBUG_instr), .START(START));
instr_mem  dut_2 (.clk(clk),.addr(addr),.instr(instr),.DEBUG_SIG(DEBUG_SIG), .DEBUG_addr(DEBUG_addr),.DEBUG_instr(DEBUG_instr),.clk_debug(clk_debug));

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
  
 always @(posedge clk)begin
   addr <= addr+1;     // simulates address coming from PC
 end



//stimulus generation
 initial begin 
	 
  nrst = 0;
  addr = 0;
#25 nrst = 1; 
   
   end 
endmodule
