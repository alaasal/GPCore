`timescale 1ns/1ns

// Request Types
`define LOAD_RET        4'b0000
`define INV_RET         4'b0011
`define ST_ACK          4'b0100
`define AT_ACK          4'b0011
`define INT_RET         4'b0111
`define TEST_RET        4'b0101
`define FP_RET          4'b1000
`define IFILL_RET       4'b0001
`define	EVICT_REQ	4'b0011
`define	ERR_RET		4'b1100
`define STRLOAD_RET     4'b0010
`define STRST_ACK       4'b0110
`define FWD_RQ_RET      4'b1010
`define FWD_RPY_RET     4'b1011
`define RSVD_RET        4'b1111



module frontend_stage(
	input logic clk,
	input logic nrst,
	input logic stall,nostall,
	input logic [1:0]killnum,
  input logic [1:0] PCSEL,		// pc select control signal
  input logic [31:0] target,

	// exceptions
	input logic exception_pending,
	input logic [31:0] epc,
	output logic instruction_addr_misaligned2, // output from front_end to decode_stage

 	output logic [31:0] pc2,	// pc at instruction mem pipe #2
 	output logic [31:0] instr2,  	// instruction output from inst memory (to decode stage)
 	output logic illegal_flag,

	output logic discardwire

    );

// registers
logic [31:0] pcReg; 	   // pipe #1 pc
logic [31:0] pcReg2;	   // pipe #2 from pc to inst mem
logic [31:0] targetsave;
logic targetcame;
logic killafterreq;
logic discardReg;
logic illegal_flagReg;

// wires
logic pc_addr_ex;
logic discard;

// Exceptions at forntend
//logic instruction_addr_misalignedReg1;
logic instruction_addr_misalignedReg2;

// wires
logic [31:0] npc;   	   // next pc wire
logic [31:0] pc;

assign pc_addr_ex = pcReg[1] & pcReg[0]; // instruction address misaligned




assign discard = (  stall) ? 1'b1 : 1'b0;
assign discardwire =discardReg;
/************************************************/
/*			First Pipe 							*/
/*			PC FETCH							*/
/************************************************/
  always_ff @(posedge clk , negedge nrst)
	begin
    if (!nrst)
    begin
		pcReg		<= 32'h40000000;
		pcReg2 		<= 32'h40000000;

		instruction_addr_misalignedReg2 <= 0;
		
		discardReg <=0;
		killafterreq<=0;
		
		targetsave  <=0;
		targetcame  <=0;
		
		end
		      
    else begin


	if ( discard || (stall && nostall ) )
	begin
		pcReg		<= pcReg2;
		pcReg2		<= pcReg2;

	end
		else if ( discardReg && state_reg == s_resp  )
	begin
		pcReg		<= pcReg2;
		pcReg2		<= pcReg2;
		targetcame <=0;

	end
	else if((npc == targetsave) )
	begin
		pcReg		<= npc;

		if(killafterreq && targetcame) pcReg2 <= pcReg2;
		else pcReg2 <=pcReg;

		targetcame <=0;


	end
	else if(killafterreq || targetcame )
	begin
		pcReg2		<= 0;

	end
	else if ( stall) begin
		pcReg		<= pcReg;
		pcReg2		<= pcReg2;

		//instruction_addr_misalignedReg1 <= 0;
			instruction_addr_misalignedReg2 <= instruction_addr_misalignedReg2;
	end

	else if( stall_mem ||  ( arb_eqmem && ~memOp_done && ~exception_pending )  )
	begin
		pcReg		<= pcReg;
		pcReg2		<= pcReg2;
		//instruction_addr_misalignedReg1 <= 0;
		instruction_addr_misalignedReg2 <= instruction_addr_misalignedReg2;
	end

	else
	begin
		pcReg		<= npc;		// PIPE1
		pcReg2		<= pcReg;

		//instruction_addr_misalignedReg1 <= pc_addr_ex;
		instruction_addr_misalignedReg2 <= pc_addr_ex;
		illegal_flagReg <= nrst;

	end

	end

    always_comb
      begin
      npc = pcReg + 4;
      if (exception_pending || (state_reg == s_resp && (resp_fire)))
      begin
        unique casez({exception_pending, PCSEL})
            3'b000: npc = targetcame ? targetsave : pcReg +4;
            3'b001: npc =  32'h40000000;
            3'b010: npc = target;
            3'b011: npc = npc;
            //Exception
            3'b1??: npc = epc;
            default: npc = pcReg + 4;
        endcase
      end
      else
      begin
          if(exception_pending)begin
            npc = (state_reg == s_req) && (exception_pending) ? epc : pcReg;
          end
        else begin
      	   npc = (state_reg == s_req) && (PCSEL[1] && ~PCSEL[0]) ? target : pcReg;
    	   end

      end
      end


    // output

	assign pc = pcReg;
	assign pc2 =  pcReg2;


// output
assign instruction_addr_misaligned2 = instruction_addr_misalignedReg2;
assign illegal_flag = illegal_flagReg;

endmodule
