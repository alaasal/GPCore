module top;

logic nrst;
logic nrst_core;
logic clk;
logic clk_core;
logic clk_debug;

logic DEBUG_SIG;
logic [31:0] DEBUG_addr;
logic [31:0] DEBUG_instr;
logic START;
logic external_interrupt;

always 
begin
    clk = 1'b0; 
    #20; // high for 20 * timescale = 20 ns

    clk = 1'b1;
    #20; // low for 20 * timescale = 20 ns
end

assign clk_core = (START == 1'b1) ? clk : 0;
assign clk_debug = (START == 1'b0) ? clk : 0;




initial 
begin 
nrst = 0;
nrst_core = 0;
external_interrupt =0;
#10
nrst = 1;
nrst_core = 1;
external_interrupt = 0;
end

core testCore(
		.DEBUG_SIG(DEBUG_SIG),				//DEBUG Signals from debug module to load a program
		.DEBUG_addr(DEBUG_addr),
		.DEBUG_instr(DEBUG_instr),

		.clk(clk_core),
		.nrst(nrst_core),
		.clk_debug(clk_debug)
	);


debug tesDebug(
	clk_debug,
	nrst,
	

	DEBUG_SIG,				//DEBUG Signals from debug module to load a program
	DEBUG_addr,
	DEBUG_instr,
	START
);

endmodule 
