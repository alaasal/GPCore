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

	output logic discardwire,


    //OpenPiton Request
	output logic[4:0] transducer_l15_rqtype,
	output logic[2:0] transducer_l15_size,
	output logic[31:0] transducer_l15_address,
	output logic[63:0] transducer_l15_data,
	output logic transducer_l15_val,
	input logic l15_transducer_ack,
	input logic l15_transducer_header_ack,


	//OpenPiton Response
	input logic l15_transducer_val,
	input logic[63:0] l15_transducer_data_0,
	input logic[63:0] l15_transducer_data_1,
	input logic[3:0] l15_transducer_returntype,
	output logic transducer_l15_req_ack,
	output logic[1:0] state_reg,
	input logic stall_mem,
	input logic arb_eqmem,
	input logic memOp_done

    );

// registers
logic [31:0] pcReg; 	   // pipe #1 pc
logic [31:0] pcReg2;	   // pipe #2 from pc to inst mem
logic [31:0] targetsave;
logic targetcame;
logic killafterreq;
logic discardReg;
logic illegal_flagReg;

// Exceptions at forntend
//logic instruction_addr_misalignedReg1;
logic instruction_addr_misalignedReg2;

// wires
logic [31:0] npc;   	   // next pc wire
logic [31:0] pc;

assign pc_addr_ex = pcReg[1] & pcReg[0]; // instruction address misaligned

//latches
logic wake_up;
localparam[1:0]   // 3 states are required for Moore
s_req = 0,
s_wait_ack =1,
s_resp = 2;
logic req_fire;
logic resp_init;
logic resp_fire;

always_ff @(posedge clk , negedge nrst)
begin
if(!nrst)
begin
	wake_up <= 0;

end
else
begin
if (wake_up == 0)
	if (l15_transducer_returntype == 4'b0111)
	wake_up <= l15_transducer_val;
end
end


assign discard = (  stall) ? 1'b1 : 1'b0;
assign discardwire =discardReg;
/************************************************/
/*			First Pipe 							*/
/*			PC FETCH							*/
/************************************************/
    always_ff @(posedge clk , negedge nrst)
	begin
        if (!nrst || !wake_up)
        begin
		pcReg		<= 32'h40000000;
		pcReg2 		<= 32'h40000000;

		instruction_addr_misalignedReg2 <= 0;
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

	end

    always_comb
      begin
      if (exception_pending || (state_reg == s_resp && (resp_fire)))
      begin
        unique casez({exception_pending, PCSEL})
            3'b000: npc = targetcame ? targetsave : pcReg +4;
            3'b001: npc =  32'h40000000;
            3'b010: npc = target;
            3'b011: npc = npc;
						//Exception
						3'b1??: npc = epc;
            default: npc = pcReg + 4 ;
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

/************************************************/
/*			First Pipe 							*/
/*			INSTR FETCH							*/
/************************************************/

// logic for pcselect if not in req time

always_ff @(posedge clk , negedge nrst)
begin

	if (!nrst) begin
		targetsave  <=0;
		targetcame  <=0;
		killafterreq<=0;
		discardReg <=0;
				end

	else
	begin
	   	if ( PCSEL[1] && ~PCSEL[0] && ~(state_reg == s_req) )
		begin
		targetsave<=target;
		targetcame<=1;
		 end
		else
		targetsave<=targetsave;


		if(~(!killnum[0] && !killnum[1]) && targetcame && state_reg == s_resp)
				killafterreq<=1;


		if (discard || (stall && nostall ))
		begin
		discardReg<=1;

		end
	end
end





assign req_fire =  l15_transducer_header_ack && transducer_l15_val && (state_reg == s_req) && wake_up ;
assign resp_fire = l15_transducer_val && (state_reg == s_resp) && (!resp_init);
assign resp_init = ( (l15_transducer_returntype != `LOAD_RET) && (l15_transducer_returntype != `IFILL_RET) && (l15_transducer_returntype != `ST_ACK) ) && l15_transducer_val;



always_ff @(posedge clk , negedge nrst)
begin

if (!nrst)
begin
	state_reg <= 3'b0;
end

else
begin
// npc logic
case(state_reg)
	s_req:
	begin
		if (req_fire)
		begin
			if(killafterreq)
			 begin 
				pcReg	<= targetsave;
				killafterreq<=0;
			 end
			else begin end



			if(l15_transducer_ack)
				state_reg <= s_resp;
			else
				state_reg <= s_wait_ack;
		end
	end
	s_wait_ack:
		if (l15_transducer_ack)
			state_reg <= s_resp;
	s_resp:
	begin
		if (resp_fire )
			begin
				state_reg 	<= s_req;

			if(discardReg) discardReg <=0;
			else begin end

			end
	end
endcase
end
end

logic[31:0] l15_data;
//code for flipping and choosing the right bits
always_comb
begin
	case(transducer_l15_address[3:2])
	2'b00: begin
		l15_data = l15_transducer_data_0[63:32];
		end
	2'b01: begin
		l15_data = l15_transducer_data_0[31:0];
		end
	2'b10: begin
		l15_data = l15_transducer_data_1[63:32];
		end
	2'b11: begin
		l15_data = l15_transducer_data_1[31:0];
		end
	default: begin
	end
	endcase
end



always_comb
begin

// npc logic
case(state_reg)
	s_req:
	begin
	   if(exception_pending)begin
	     transducer_l15_address <= epc;
	     end
	     else begin
		transducer_l15_address <= (PCSEL[1] && ~PCSEL[0]) ? target : pc;
		end
	    transducer_l15_rqtype	<= 0;
		transducer_l15_size	<= 8;
		transducer_l15_val	<= 1 && wake_up;
		transducer_l15_req_ack	<= resp_init && wake_up;
		instr2 <= 32'h33;				//Inster no op when cache is busy
	end
	s_wait_ack:
	begin
		transducer_l15_address <= pc;
	    transducer_l15_rqtype	<= 0;
		transducer_l15_size	<= 8;
		transducer_l15_val	<= 0;
		transducer_l15_req_ack	<= resp_init && wake_up;
		instr2 <= 32'h33;				//Inster no op when cache is busy
	end
	s_resp:
	begin
		transducer_l15_address	<= pc;
	    transducer_l15_rqtype	<= 0;
		transducer_l15_size	<= 8;
		transducer_l15_val	<= 0;
		transducer_l15_req_ack	<= resp_init || l15_transducer_val;

		instr2 <= (l15_transducer_val) ? (killafterreq || (killnum[0] && !killnum[1]) || discardReg ||discard || (stall &&nostall ) )  ? 32'h33: {l15_data[7:0], l15_data[15:8], l15_data[23:16], l15_data[31:24]} : 32'h33;	 //Inster no op when cache is busy
	end  // issue will stall next pipes untill arb_state=arb_mem
endcase

end

// output
assign instruction_addr_misaligned2 = instruction_addr_misalignedReg2;
assign illegal_flag = illegal_flagReg;

endmodule
