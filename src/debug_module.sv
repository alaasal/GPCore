module debug(
	input logic clk,
	input logic nrst,
	

	output logic DEBUG_SIG,				//DEBUG Signals from debug module to load a program
	output logic [31:0] DEBUG_addr,
	output logic [31:0] DEBUG_instr,
	output logic START
);

//TODO: enhance the debugging

logic [20:1] offset = 20'b1;
logic [20:1] imm = {offset[20], offset[10:1], offset[11], offset[19:12]};
logic [4:0] dest = 5'b1; 
logic [6:0] JAL = 7'b1101111;
//jalr = {};	//JALR 
logic [31:0] jal0  = {imm, dest, JAL}; //JAL x0, 1 (unconditional jump)
//logic [31:0] jal1  = {,};

parameter NUM_Of_INSTRS = 4;
logic [31:0] instrs [3:0] = {32'h0 ,32'h0 ,32'h0, jal0};  // 32'h2081B3 , 0000000 00110 00101 001  11111110 0011 
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

	