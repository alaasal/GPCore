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
	input logic stall,
	
    input logic [1:0] PCSEL,		// pc select control signal
    input logic [31:0] target,
	input logic [1:0] stallnumin,

    output logic [31:0] pc2,	// pc at instruction mem pipe #2
    output logic [31:0] instr2,  	// instruction output from inst memory (to decode stage)
    

    //OpenPiton Request
	output logic[4:0] transducer_l15_rqtype, 
	output logic[2:0] transducer_l15_size,
	output logic[31:0] transducer_l15_address,
	output logic[31:0] transducer_l15_data,
	output logic transducer_l15_val,
	input logic l15_transducer_ack,
	input logic l15_transducer_header_ack,


	//OpenPiton Response
	input logic l15_transducer_val,
	input logic[63:0] l15_transducer_data_0, 
	input logic[63:0] l15_transducer_data_1, 
	input logic[3:0] l15_transducer_returntype,
	output logic transducer_l15_req_ack,
	output logic[1:0] state_reg

    );

// registers
logic [31:0] pcReg; 	   // pipe #1 pc
logic [31:0] pcReg2;	   // pipe #2 from pc to inst mem

// wires
logic [31:0] npc;   	   // next pc wire
logic [31:0] pc; 
//latches
logic wake_up;
localparam[1:0]   // 3 states are required for Moore
s_req = 0,
s_resp = 1;
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

		end
        else begin	
	//stallnumin<=stallnuminin;
	if ( stall&&!stallnumin[1] && !stallnumin[0]) begin 
		pcReg		<= pcReg-4;		
		pcReg2		<= pcReg2-4;
	end
	else if(stall && !(!stallnumin[1] && stallnumin[0]) ) 
	begin 
		pcReg		<= pcReg;		
		pcReg2		<= pcReg2;
	end 
	else if(stall &&!stallnumin[1] && stallnumin[0] )
	begin 
		pcReg		<= npc;		
		pcReg2		<= pcReg;
	end 
	else if(stall  ) 
	begin 
		pcReg		<= pcReg;		
		pcReg2		<= pcReg2;
	end 
	else 
	begin 
		pcReg		<= npc;		// PIPE1
		pcReg2		<= pcReg;
	end

	end 

	end 

    always_comb
      begin
      if (state_reg == s_resp && (resp_fire))
      begin
        unique case(PCSEL)
            0: npc = pcReg +4;
            1: npc =  32'h40000000;
            2: npc = target;
            3: npc = npc;
            default: npc = pcReg + 4 ;
        endcase 
      end
      else
      begin
      	npc = pcReg;
      end
      end

    // output

	assign pc = (stall && !stallnumin[1] && !stallnumin[0]) ? pcReg-4: pcReg;
	assign pc2 = (stall && !stallnumin[1] && !stallnumin[0]) ? pcReg2 - 4 : pcReg2;

/************************************************/
/*			First Pipe 							*/
/*			INSTR FETCH							*/
/************************************************/









assign req_fire =  l15_transducer_header_ack && transducer_l15_val && (state_reg == s_req) && wake_up;
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
			state_reg <= s_resp;
	end
	s_resp:
	begin
		if (resp_fire)
			state_reg <= s_req;
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
		transducer_l15_address <= pc;
	    transducer_l15_rqtype	<= 0;
		transducer_l15_size	<= 8;
		transducer_l15_val	<= 1 && wake_up;
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
		instr2 <= (l15_transducer_val) ? l15_data : 32'h33;	 //Inster no op when cache is busy
	end  // issue will stall next pipes untill arb_state=arb_mem 
endcase
       
end
       

endmodule