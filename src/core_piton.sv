// Requests
`define	LOAD_RQ		4'b0000
`define	STORE_RQ	4'b0001

// Responds
`define LOAD_RET    4'b0000
`define ST_ACK      4'b0100
`define INT_RET     4'b0111

//Message size
`define MSG_DATA_SIZE_WIDTH     3
`define MSG_DATA_SIZE_0B        3'b000
`define MSG_DATA_SIZE_1B        3'b001
`define MSG_DATA_SIZE_2B        3'b010
`define MSG_DATA_SIZE_4B        3'b011

module core_piton(
    input logic clk, nrst,
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
	input logic [3:0] l15_core_returntype,
    
    input logic l15_core_val,
    input logic l15_core_ack,
	input logic l15_core_header_ack,
    output logic core_l15_req_ack,

    output logic [31:0] piton_out
);

enum logic[1:0] {s_req, s_idle, s_resp} state_reg;

logic req_fire;
logic resp_int;
logic resp_fire;

logic [31:0] wdata;
logic [3:0]  bw;

logic [3:0] rqtypeReg;

//fire request when: cache is ready, and a memory operation is under execution.
assign req_fire  = l15_core_ack && l15_core_header_ack && core_l15_val && (state_reg == s_req) && m_op6;    
//receive response when: data is available, and a response is required.
assign resp_fire = l15_core_val && (state_reg == s_idle);

//endian conversion
assign wdata = {data_in6[7:0], data_in6[15:8], data_in6[23:16], data_in6[31:24]};

assign bw = {bw36, bw26, bw16, bw06};

always_ff @(posedge clk , negedge nrst) begin
    if (!nrst) state_reg <= s_req;
    else begin
        case(state_reg)
            s_req: begin
                if (req_fire) begin 
                    state_reg <= s_idle;
                    rqtypeReg <= core_l15_rqtype;
                end
            end s_idle: begin
                if (resp_fire) begin
                    case(rqtypeReg)
                        `LOAD_RQ:  if (l15_core_returntype == `LOAD_RET) state_reg <= s_resp;
                        `STORE_RQ: if (l15_core_returntype == `ST_ACK) state_reg <= s_resp;
                        default: state_reg <= s_idle;
                    endcase
                end
            end s_resp: state_reg <= s_req;
        endcase

    end
end

always_comb begin
    case(state_reg)
        s_req: begin
            core_l15_address = addr6;        
            core_l15_data    = wdata;

            core_l15_val	 = 1;
            
            //store operation
            if (bw) begin
                core_l15_rqtype  = `STORE_RQ;
                core_l15_data    = wdata;
                case (bw)
                    4'b1111: core_l15_size	 = `MSG_DATA_SIZE_4B;
                    4'b1100, 4'b0011: core_l15_size	 = `MSG_DATA_SIZE_2B;
                    4'b0001, 4'b0010, 4'b0100, 4'b1000: core_l15_size	 = `MSG_DATA_SIZE_1B;
                    default: core_l15_size	 = `MSG_DATA_SIZE_0B;
                endcase

            //load opertion
            end else if (m_rd6) begin
                core_l15_rqtype  = `LOAD_RQ;
                core_l15_size    = `MSG_DATA_SIZE_4B;
            end
        
        end s_idle: begin
            core_l15_val	 = 0;
            if (resp_fire) core_l15_req_ack = 1;
            
        end s_resp: begin
            core_l15_val	 = 0;
            core_l15_req_ack = 1;

            piton_out = {l15_core_data_0[7:0], l15_core_data_0[15:8],
                    l15_core_data_0[23:16], l15_core_data_0[31:24]};
        end
    endcase
end
endmodule
