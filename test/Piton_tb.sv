`timescale 1 ns / 1 ns

import pkg_instructions::*;
module openpiton;

logic nrst;
logic clk;

//OpenPiton Request
logic[4:0] transducer_l15_rqtype; 
logic[2:0] transducer_l15_size;
logic[31:0] transducer_l15_address;
logic[31:0] transducer_l15_data;
logic transducer_l15_val;
logic l15_transducer_ack;
logic l15_transducer_header_ack;

//OpenPiton Response
logic l15_transducer_val;
logic[63:0] l15_transducer_data_0; 
logic[63:0] l15_transducer_data_1;  
logic[31:0] l15_transducer_returntype;
logic transducer_l15_req_ack;

assign l15_transducer_ack = transducer_l15_val;
//OpenPitonFSM with 4 Instruction and Interrupt
initial
begin
	if (!nrst)
	begin
		l15_transducer_val			<= 0;
		l15_transducer_header_ack 	<= 0;
	end
	else 
	begin
	// Step 1: Before Sending WAKE UP Int
		//Just do nothing and see the results xD
		//assert(testCore.frontend.instr2 == 32'h33);	//PASSED
	#100
	// Step 2: Sending WAKE UP Int
		l15_transducer_val			<= 1;
		l15_transducer_header_ack 	<= 0;
		l15_transducer_returntype	<= 4'b0111;
	#50 
	//reset
		l15_transducer_val			<= 0;
		l15_transducer_header_ack 	<= 0;
	#50
	//Setting the cache ready
		l15_transducer_header_ack 	<= 1;
	#200
	// Step 3: Sending Instruction with no MemOps or hazards
	// Step 31: Sending Add Instruction
	//OpenPiton Response 10110011
		l15_transducer_val <= 1;
		//l15_transducer_data_0 <= 64'h1080B3;
		//l15_transducer_data_1 <= 64'h1080B3;
		l15_transducer_returntype <= 4'b0000;
        
		l15_transducer_data_0 <= {ADDI,ADD};
		l15_transducer_data_1 <= {SW,LW};  //*PASSED*
        /*After the above instructions run:
            1- reg 20 = 5
            2- reg 2 = 10
			3- sw address 0 data 10
           	4- reg 21 = 10

            That is if they are executed in this order ADDI, ADD, SW, LW.
            IF not, just change the order. 
        */


        // The following section is to be removed once the piton mux is established
        // It emulates piton response 
 

	

	// Step 34: Sending Mul Instruction

	// Step 4: Sending Instructions with no MemOps but with hazards  ** Nour **

	// Step 5: Sending Instruction with MemOps but no hazards
	// Step 6 Sending Instruction with Memops and hazards
	end
end 

// Clock Generation
always 
begin
    clk = 1'b0; 
    #20; // high for 20 * timescale = 20 ns

    clk = 1'b1;
    #20; // low for 20 * timescale = 20 ns
end

// Asserting the rest signal
initial 
begin 
nrst = 0;
#10
nrst = 1;
end

// Core initalization
core testCore(
		.clk(clk),
		.nrst(nrst),
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
		.transducer_l15_req_ack(transducer_l15_req_ack)

	);



endmodule 