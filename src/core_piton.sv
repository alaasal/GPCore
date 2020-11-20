// Requests
`define	LOAD_RQ		5'b00000
`define	IMISS_RQ	5'b10000
`define	STORE_RQ	5'b00001
`define	CAS1_RQ		5'b00010
`define	CAS2_RQ		5'b00011
`define	SWAP_RQ		5'b00110
`define STQ_RQ      5'b00111
`define INT_RQ      5'b01001
`define	STRLOAD_RQ	5'b00100
`define	STRST_RQ	5'b00101
`define FWD_RQ      5'b01101
`define FWD_RPY     5'b01110
`define RSVD_RQ     5'b11111

// Responds
`define LOAD_RET    4'b0000
`define IFILL_RET   4'b0001
`define ST_ACK      4'b0100
`define INV_RET     4'b0011
`define AT_ACK      4'b0011
`define INT_RET     4'b0111
`define TEST_RET    4'b0101
`define FP_RET      4'b1000
`define	EVICT_REQ	4'b0011
`define	ERR_RET		4'b1100
`define STRLOAD_RET 4'b0010
`define STRST_ACK   4'b0110
`define FWD_RQ_RET  4'b1010
`define FWD_RPY_RET 4'b1011
`define RSVD_RET    4'b1111

//Message size
`define MSG_DATA_SIZE_WIDTH     3
`define MSG_DATA_SIZE_0B        3'b000
`define MSG_DATA_SIZE_1B        3'b001
`define MSG_DATA_SIZE_2B        3'b010
`define MSG_DATA_SIZE_4B        3'b011

//Unused message sizes
//`define MSG_DATA_SIZE_8B        3'b100
//`define MSG_DATA_SIZE_16B       3'b101
//`define MSG_DATA_SIZE_32B       3'b110
//`define MSG_DATA_SIZE_64B       3'b111

module core_piton(
    //core -> memory controls
    input logic [31:0] addr6,
    input logic [31:0] data_in6,          //memory input data
    //input logic [1:0]  baddr6,
    //input logic gwe6,
    input logic m_rd6,
    input logic bw06,
    input logic bw16,
    input logic bw26,
    input logic bw36,
    input logic m_op6, 

    //OpenPiton Request
	output logic [5:0] core_l15_rqtype, 
	output logic [2:0] core_l15_size,
	output logic [31:0] core_l15_address,
	output logic [31:0] core_l15_data,
	
    output logic core_l15_val,

	//OpenPiton Response
	input logic [31:0] l15_core_data_0, 
	input logic [31:0] l15_core_data_1, 
	input logic [31:0] l15_core_data_2, 
	input logic [31:0] l15_core_data_3, 
	input logic [3:0] l15_core_returntype,
    
    input logic l15_core_val,
    input logic l15_core_ack,
	input logic l15_core_header_ack,
);

enum logic[1:0] {s_req, s_idle, s_resp} state_reg;

logic req_fire;
logic resp_int;
logic resp_fire;

logic [31:0] wdata;
logic [3:0]  bw;

//fire request when: cache is ready, and a memory operation is under execution.
assign req_fire  = l15_core_ack && l15_core_header_ack && core_l15_val && (state_reg == s_req) && m_op;    
//receive response when: data is available, and a response is required.
assign resp_fire = l15_core_val && (state_reg == s_idle);

//endian conversion
assign wdata = {data_in6[7:0], data_in6[15:8], data_in6[23:16], data_in6[31:24]};

assign bw = {bw36, bw26, bw16, bw06}

always_ff @(posedge clk , negedge nrst) begin
    if (!nrst) state_reg <= s_req;
    else begin
        case(state_reg)
        s_req: begin
		    core_l15_address <= addr6;        
            core_l15_data    <= wdata;

            core_l15_val	 <= 1;
            
            if (bw) begin
                core_l15_rqtype  <= `STORE_RQ;
                core_l15_data    <= wdata;
                case (bw)
                    4'b1111: core_l15_size	 <= `MSG_DATA_SIZE_4B;
                    4'b1100, 4'b0011: core_l15_size	 <= `MSG_DATA_SIZE_2B;
                    4'b0001, 4'b0010, 4'b0100: 4'b1000: core_l15_size	 <= `MSG_DATA_SIZE_1B;
                    default: core_l15_size	 <= `MSG_DATA_SIZE_0B;
                endcase

            end else if (m_rd6) begin
                core_l15_rqtype  <= `LOAD_RQ;
                core_l15_size    <= `MSG_DATA_SIZE_4B;
            
            end else begin //this will never happen
                core_l15_size	 <= `MSG_DATA_SIZE_0B;
                core_l15_rqtype  <= `LOAD_RQ;

            if (req_fire) state_reg <= s_idle;
        
        end s_idle: begin
		    core_l15_address <= core_l15_address;
            core_l15_data    <= core_l15_data;
	        core_l15_rqtype  <= core_l15_rqtype;
		    core_l15_size	 <= core_l15_size;
		    core_l15_val	 <= 0;
		    
            if (resp_fire) state_reg <= s_resp;
        
        end s_resp: begin
		    core_l15_address <= core_l15_address;
            core_l15_data    <= core_l15_data; 
	        core_l15_rqtype  <= core_l15_rqtype;
	        core_l15_size    <= core_l15_size;
		    core_l15_val	 <= 0;
		    core_l15_req_ack <= 1;
		    
            state_reg <= s_req;
	    end
endcase