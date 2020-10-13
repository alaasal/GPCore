module debug(
	input logic clk,
	input logic nrst,
	

	output logic DEBUG_SIG,				//DEBUG Signals from debug module to load a program
	output logic [31:0] DEBUG_addr,
	output logic [31:0] DEBUG_instr,
	output logic START
);

//TODO: enhance the debugging

/*logic [20:1] offset = 20'b1;
logic [20:1] imm = {offset[20], offset[10:1], offset[11], offset[19:12]};
logic [4:0] dest = 5'b6; 
logic [6:0] JAL = 7'b1101111;*/
//jalr = {};	//JALR 
//logic [31:0] jal0  = {7'b0000001,5'b2,5'b1, 3'b0,5'b6 , 7'b0110011}; //JAL x0, 1 (unconditional jump)

//ogic [31:0] jal1  = {7'b0000000,5'b6,5'b5, 3'b0,5'b7, 7'b0110011}; //JAL x0, 1 (unconditional jump)
//logic [31:0] jal1  = {,};

parameter NUM_Of_INSTRS = 4;
logic [31:0] instrs [3:0] = {32'h0 ,32'h0 ,{7'h0,5'h6,5'h5, 3'h0,5'h7, 7'b0110011}, {7'h1,5'h2,5'h1, 3'h0,5'h6 , 7'b0110011}};  // 32'h2081B3 , 0000000 00110 00101 001  11111110 0011 
//parameter NUM_Of_INSTRS = 2;
//logic [31:0] instrs[1:0] = {32'b00000000011100011000001000110011, 32'b 00000000011000001000000110110011};  // 32'h2081B3 , 0000000 00110 00101 001  11111110 0011 
logic [2:0] instrs_index;




	always_ff @(posedge clk, negedge nrst)
	  begin
		if (!nrst)
		  begin
			DEBUG_SIG <= 0;
			DEBUG_addr <= -1;
			instrs_index <= 0;
			DEBUG_instr <= instrs[0];
			START <= 0;
		  end
		else
		  begin
			DEBUG_instr <= instrs[instrs_index];
			instrs_index <= instrs_index + 1;		
			DEBUG_addr <= DEBUG_addr + 1'b1;
			START <= (instrs_index > (NUM_Of_INSTRS) ) ;
			DEBUG_SIG <= ~(instrs_index == (NUM_Of_INSTRS));
		  end
	  end
	

endmodule

	