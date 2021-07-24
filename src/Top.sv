module top(
input logic clk, nrst,
input logic external_interrupt
);

//logic nrst;
logic nrst_core;
//logic clk;
logic clk_core;
logic clk_debug;

logic DEBUG_SIG;
logic [31:0] DEBUG_addr;
logic [31:0] DEBUG_instr;
logic START;

//OpenPiton Request
	logic[4:0] transducer_l15_rqtype = 0;
	logic[2:0] transducer_l15_size = 0;
	logic[31:0] transducer_l15_address = 0;
	logic[63:0] transducer_l15_data = 0;
	logic transducer_l15_val = 0;
	logic l15_transducer_ack = 0;
	logic l15_transducer_header_ack = 0;


	//OpenPiton Response
	logic l15_transducer_val = 0;
	logic[63:0] l15_transducer_data_0 = 0;
	logic[63:0] l15_transducer_data_1 = 0;
	logic[4:0] l15_transducer_returntype = 0;
	logic transducer_l15_req_ack = 0;

	// Asynchronus interrupt
	//logic external_interrupt = 0;
	
/*always 
begin
    clk = 1'b0; 
    #20; // high for 20 * timescale = 20 ns

    clk = 1'b1;
    #20; // low for 20 * timescale = 20 ns
end*/

assign clk_core = (START == 1'b1) ? clk : 0;
assign clk_debug = (START == 1'b0) ? clk : 0;




/*initial 
begin 
nrst = 0;
nrst_core = 0;
#10
nrst = 1;
nrst_core = 1;
end*/

core testCore(
		.DEBUG_SIG(DEBUG_SIG),				//DEBUG Signals from debug module to load a program
		.DEBUG_addr(DEBUG_addr),
		.DEBUG_instr(DEBUG_instr),

		.clk(clk_core),
		.nrst(nrst),
		.clk_debug(clk_debug),
		
		//OpenPiton Request
	.transducer_l15_rqtype(transducer_l15_rqtype),
	.transducer_l15_size(transducer_l15_size),
	.transducer_l15_address(transducer_l15_address),
	.transducer_l15_data(transducer_l15_data),
	.transducer_l15_val(transducer_l15_val),
	.l15_transducer_ack(l15_transducer_ack),
	.l15_transducer_header_ack(l15_transducer_header_ack),


	//OpenPiton Response
	.l15_transducer_val(l15_transducer_val),
	.l15_transducer_data_0(l15_transducer_data_0),
	.l15_transducer_data_1(l15_transducer_data_1),
	.l15_transducer_returntype(l15_transducer_returntype),
	.transducer_l15_req_ack(transducer_l15_req_ack),

	// Asynchronus interrupt
	.external_interrupt(external_interrupt)
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