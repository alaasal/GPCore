module debug(
	input logic clk,
	input logic nrst,


	output logic DEBUG_SIG,				//DEBUG Signals from debug module to load a program
	output logic [31:0] DEBUG_addr,
	output logic [31:0] DEBUG_instr,
	output logic START
);

logic [20:1] imm = {1'b0, 10'b10, 1'b0, 8'b0};
parameter NUM_Of_INSTRS = 10;

logic [31:0] instrs[9:0] = {{12'h7,5'b0, 3'b111,5'b111,7'b0010011},{12'h8,5'b0, 3'b111,5'b110,7'b0010011},32'hffff,{12'h5,5'b0, 3'b111,5'b110,7'b0010011},{12'h2,5'b0, 3'b111,5'b011,7'b0010011},{12'h2,5'b0, 3'b111,5'b1,7'b0010011},{12'h1,5'b0, 3'b111,5'b1110,7'b0010011},{12'h100,5'b111, 3'b101,5'b1, 7'b1110011},{12'h300,5'b11111, 3'b101,5'b1, 7'b1110011},{12'h305,5'b110, 3'b101,5'b1, 7'b1110011}};

//32'hffff,{12'h300,5'b11111, 3'b101,5'b1, 7'b1110011}
/*{7'h0,5'h13,5'h14, 3'h0,5'h15 , 7'b0110011},
{7'h0,5'h10,5'h14, 3'h0,5'h12 , 7'b0110011},
{7'h0,5'ha,5'hb, 3'h0,5'hc , 7'b0110011},
{7'h0,5'h3,5'h9, 3'h0,5'h4 , 7'b0110011},
{7'h0,5'h10,5'h7, 3'h0,5'h6 , 7'b0110011}, // make rs1 or rs2 = 3
//{7'h0,5'h10,5'h4, 3'h0,5'h3 , 7'b0110011},

{7'h0,5'h5,5'h10, 3'h0,5'h6 , 7'b0110011},//{imm,5'b1,7'b1101111},//{7'h0,5'h5,5'h18, 3'h0,5'h6 , 7'b1100011},//{7'h0,5'h5,5'h18, 3'h0,5'h6 , 7'b1100011}
{7'h0,5'h5,5'h18, 3'h0,5'h6 , 7'b0110011},
{imm,5'b1,7'b1101111},

{7'h0,5'h16,5'h17, 3'h0,5'h10, 7'b0110011}};  // 32'h2081B3 , 0000000 00110 00101 001  11111110 0011 */
logic [9:0] instrs_index;

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
