//`include "mem_wrap.sv"
//`include "mem_wrap.sv"
//description: This is a memory wrapper,
//it generates the addresses and control signals for the data memory,
//it also performs the proper extension of outputs. 

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

module mem_decode(
    input logic clk, nrst,
    input logic [3:0] mem_op4,             //memory operation type
    input logic [31:0] op_a4,        //base address
    input logic [31:0] op_b4,        //src for store ops, I_imm offset for load ops
    input logic [31:0] S_imm4,       //S_imm offset
	input logic stall_mem,dmem_finished,
	

    output logic [31:0] addr6,
    output logic [31:0] data_in6, 
    output logic [1:0]  baddr6,
    output logic gwe6, rd6,
    output logic bw06, bw16, bw26, bw36,
    output logic m_op6,
    output logic addr_misaligned6,
    output logic ld_addr_misaligned6,
    output logic samo_addr_misaligned6,

    output logic [3:0] mem_op6
);
    //pipe5 registers
    logic [3:0] mem_opReg5; 
    logic [31:0] op_aReg5, op_bReg5, S_immReg5;

    //pipe5 outputs
    logic [3:0]mem_op5;
    logic [31:0] op_a5, op_b5, S_imm5;

    //pipe5 memory controls
    logic gwe5, rd5; 
    logic m_op5;
    logic [31:0] addr5, data_in5;
    logic [1:0] addr_mis5;
    logic addr_misaligned5;
    logic ld_addr_misaligned5;
    logic samo_addr_misaligned5;
    logic bw05, bw15, bw25, bw35;

    //pip6 registers
    logic gweReg6, rdReg6;
    logic m_opReg6;
    logic [3:0] mem_opReg6;
    logic [31:0] addrReg6, data_inReg6;
    logic addr_misalignedReg6;
    logic ld_addr_misalignedReg6;
    logic samo_addr_misalignedReg6;
    logic bw0Reg6, bw1Reg6, bw2Reg6, bw3Reg6;
	//logic m_rd6;

    //pipe5 memory controls
    logic [3:0][7:0] data_out6;
	logic memstallReg;
	logic memstallwire;

assign memstallwire = ( dmem_finished && stall_mem)  ? 1'b0 : memstallReg;
 
    //pipe5
    always_ff @(posedge clk, negedge nrst) begin
        if (!nrst) begin
            mem_opReg5  <= 0;
            op_aReg5    <= 0;
            op_bReg5    <= 0;
            S_immReg5   <= 0;
			memstallReg	<= 0;
        end else begin	
		if(stall_mem && ~(memstallwire) ) begin
            mem_opReg5  <= mem_op4;
            op_aReg5    <= op_a4;
            op_bReg5    <= op_b4;
            S_immReg5   <= S_imm4;
		end 
		else if (stall_mem && memstallwire && memstallReg) begin 
            mem_opReg5  <= mem_opReg5;
            op_aReg5    <= op_aReg5;
            op_bReg5    <= op_bReg5;
            S_immReg5   <= S_immReg5;
		end
		else begin
            mem_opReg5  <= mem_op4;
            op_aReg5    <= op_a4;
            op_bReg5    <= op_b4;
            S_immReg5   <= S_imm4;

		end
		if(stall_mem) memstallReg <=1;
		if ( dmem_finished) memstallReg<=0;
        end
    end

    //pipe6
    always_ff @(posedge clk, negedge nrst) begin
        if (!nrst) begin
            gweReg6                  <= 0;
            rdReg6                   <= 0;
            mem_opReg6               <= 0;
            addrReg6                 <= 0;
            data_inReg6              <= 0;
            addr_misalignedReg6      <= 0;
            ld_addr_misalignedReg6   <= 0;
            samo_addr_misalignedReg6 <= 0;
            bw0Reg6                  <= 0; 
            bw1Reg6                  <= 0; 
            bw2Reg6                  <= 0; 
            bw3Reg6                  <= 0;
            m_opReg6                 <= 0;
        end else begin
            gweReg6                  <= gwe5;
            rdReg6                   <= rd5;
            mem_opReg6               <= mem_op5;
            addrReg6                 <= addr5;
            data_inReg6              <= data_in5;
            addr_misalignedReg6      <= addr_misaligned5;
            ld_addr_misalignedReg6   <= ld_addr_misaligned5;
            samo_addr_misalignedReg6 <= samo_addr_misaligned5;
            bw0Reg6                  <= bw05; 
            bw1Reg6                  <= bw15; 
            bw2Reg6                  <= bw25; 
            bw3Reg6                  <= bw35;
            m_opReg6                 <= m_op5;
        end
    end

    assign mem_op5  = mem_opReg5;
    assign op_a5    = op_aReg5;
    assign op_b5    = op_bReg5;
    assign S_imm5   = S_immReg5;

    //mem_op
    //mem_op[3]   -> store = 1, load = 0
    //mem_op[2:1] -> word = 11, half = 01, byte = 10
    //mem_op[0]   -> signed = 1, unsigned = 0

    /*
    --------------------|
    mem_op  | operation |
    --------------------|
    4'b0000 | no_mem_op |
    --------------------|
    4'b1111 | SW        |
    4'b1011 | SH        |
    4'b1101 | SB        |
    --------------------|
    4'b0111 | LW        |
    4'b0011 | LH        |
    4'b0010 | LHU       |
    4'b0101 | LB        |
    4'b0100 | LBU       |
    --------------------|
    */ 
    
                              //s imm + offset   //i imm + offset  
    assign addr5    = (mem_op5[3])? (S_imm5 + op_a5) : (op_b5 + op_a5);
    
    assign m_op5 = |mem_op5;  //is there a memory op?
    
    //generate address misaligned exception
    assign addr_mis5[0]          = mem_op5[1] & addr5[0];
    assign addr_mis5[1]          = mem_op5[1] & mem_op5[2] & addr5[1];
    assign addr_misaligned5      = addr_mis5[0] | addr_mis5[1];
    assign ld_addr_misaligned5   = addr_misaligned5 & ~mem_op5[3];   //load misalignment
    assign samo_addr_misaligned5 = addr_misaligned5 & mem_op5[3];           //store and atomic misalignment

    assign gwe5 = &mem_op5 & ~addr_misaligned5;
    assign rd5  = !mem_op5[3] & ~addr_misaligned5;

/*
--------------------------------------------------------------
| i_sh | i_sb | addr5[1] | addr5[0] || BW0 | BW1 | BW2 | BW3 |
-------------------------------------------------------------
|   0  |   1  |    0     |    0     ||  1  |  0  |  0  |  0  |
|   0  |   1  |    0     |    1     ||  0  |  1  |  0  |  0  |
|   0  |   1  |    1     |    0     ||  0  |  0  |  1  |  0  |
|   0  |   1  |    1     |    1     ||  0  |  0  |  0  |  1  |
--------------------------------------------------------------
|   1  |   0  |    0     |    0     ||  1  |  1  |  0  |  0  |
|   1  |   0  |    0     |    1     ||        ILLEGAL        |
|   1  |   0  |    1     |    0     ||  0  |  0  |  1  |  1  |
|   1  |   0  |    1     |    1     ||        ILLEGAL        |
--------------------------------------------------------------
*/
    //byte write enable
    assign bw05 = ((~addr5[1]  & ~addr5[0]) & mem_op5[3] & ~addr_misaligned5) | gwe5;
    assign bw25 = ((addr5[1]   & ~addr5[0]) & mem_op5[3] & ~addr_misaligned5) | gwe5;
    assign bw15 = (~addr5[1]   & ((addr5[0] & mem_op5[2])  | (~addr5[0] & mem_op5[1])) & mem_op5[3] & ~addr_misaligned5) | gwe5; 
    assign bw35 = (addr5[1]    & ((addr5[0] & mem_op5[2])  | (~addr5[0] & mem_op5[1])) & mem_op5[3] & ~addr_misaligned5) | gwe5;
    
    always_comb begin
        case (mem_op5[2:1])
            2'b11: data_in5 = op_b5; //SW
            2'b01: data_in5 = {op_b5[15:0], op_b5[15:0]}; //SH
            2'b10: data_in5 = {op_b5[7:0], op_b5[7:0], op_b5[7:0], op_b5[7:0]}; //SB
            default: data_in5 = op_b5; //TO SUPPORT PREVIOUS CODE OF DATA_IN
        endcase
    end 

    assign gwe6                  = gweReg6;
    assign rd6                   = rdReg6;
    assign mem_op6               = mem_opReg6;
    assign addr6                 = addrReg6;
    assign data_in6              = data_inReg6;
    assign addr_misaligned6      = addr_misalignedReg6;
    assign ld_addr_misaligned6   = ld_addr_misalignedReg6;
    assign samo_addr_misaligned6 = samo_addr_misalignedReg6;
    assign bw06                  = bw0Reg6;
    assign bw16                  = bw1Reg6;
    assign bw26                  = bw2Reg6;
    assign bw36                  = bw3Reg6;
    assign m_op6                 = m_opReg6;
/*
    data_mem dmem (
    .clk        (clk),
//	.nrst	(nrst),
    .gwe        (gwe6),
    .rd         (rd6),
    .bw0        (bw06),         
    .bw1        (bw16),
    .bw2        (bw26),
    .bw3        (bw36),
    .addr       (addr6),
    .data_in    (data_in6),
    .data_out   (data_out6)
    );
*/
endmodule

module piton_fsm(
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
    input logic [3:0] mem_op6,

    //OpenPiton Request
	output logic [3:0] core_l15_rqtype, 
	output logic [2:0] core_l15_size,
	output logic [31:0] core_l15_address,
	output logic [63:0] core_l15_data,
	
    output logic core_l15_val,

	//OpenPiton Response
	input logic [63:0] l15_core_data_0, 
    input logic [63:0] l15_core_data_1, 
	input logic [3:0] l15_core_returntype,
    
    input logic l15_core_val,
    input logic l15_core_ack,
	input logic l15_core_header_ack,
    output logic core_l15_req_ack,

    output logic [31:0] mem_out6,
    output logic memOp_done
);

enum logic[1:0] {s_req, s_resp} state_reg;

logic req_fire;
logic resp_int;
logic resp_fire;

logic [31:0] wdata;
logic [3:0]  bw;
logic [3:0] mem_opReg;
logic [1:0] baddr;

logic [3:0] rqtypeReg;
logic [31:0] addrReg, rdata;
logic [3:0][7:0] piton_out;

//fire request when: cache is ready, and a memory operation is under execution.
assign req_fire  = l15_core_header_ack && (state_reg == s_req) && m_op6;    
//receive response when: data is available, and a response is required.
assign resp_fire = l15_core_val && (state_reg == s_resp);

//endian conversion
assign wdata = {data_in6[7:0], data_in6[15:8], data_in6[23:16], data_in6[31:24]};

assign bw = {bw36, bw26, bw16, bw06};

assign core_l15_req_ack = resp_fire || l15_core_val;

always_ff @(posedge clk , negedge nrst) begin
    if (!nrst) begin
        state_reg       <= s_req;
    end else begin
        case(state_reg)
            s_req: begin
                if (req_fire) begin
                    state_reg <= s_resp;         
                    mem_opReg <= mem_op6;     
                end
            end s_resp: begin
                if (resp_fire) begin
                    case(core_l15_rqtype)
                        `LOAD_RQ:  if (l15_core_returntype == `LOAD_RET) state_reg <= s_req;
                        `STORE_RQ: if (l15_core_returntype == `ST_ACK) state_reg <= s_req;
                        default: state_reg <= state_reg;
                    endcase
                end
            end 
        endcase 
    end
end

always_comb begin
    case(state_reg)
    s_req: begin
        memOp_done       = 0;
        baddr            = addr6[1:0];
        core_l15_data    = {wdata, wdata};
        core_l15_address = addr6;
        core_l15_val	 = m_op6;
        //store operation
        if (bw) begin
            core_l15_rqtype  = `STORE_RQ;
            core_l15_data    = {wdata, wdata};
            case (bw)
                4'b1111: core_l15_size	= `MSG_DATA_SIZE_4B;
                4'b1100, 4'b0011: core_l15_size	 = `MSG_DATA_SIZE_2B;
                4'b0001, 4'b0010, 4'b0100, 4'b1000: core_l15_size	 = `MSG_DATA_SIZE_1B;
                default: core_l15_size	 = `MSG_DATA_SIZE_0B;
            endcase

        //load opertion
        end else if (m_rd6) begin
            core_l15_rqtype  = `LOAD_RQ;
            core_l15_size    = `MSG_DATA_SIZE_4B;
        end                 

    end s_resp: begin
        core_l15_val = 0;
        if(l15_core_val)
            memOp_done = 1;
    end
endcase 
end

always_comb begin
    if (core_l15_rqtype == `LOAD_RQ & l15_core_val == 1) begin
        case(core_l15_address[3:2])
            2'b00: rdata = l15_core_data_0[63:32];
            2'b01: rdata = l15_core_data_0[31:0];
            2'b10: rdata = l15_core_data_1[63:32];
            2'b11: rdata = l15_core_data_1[31:0];
        endcase

        piton_out = {rdata[7:0], rdata[15:8], rdata[23:16], rdata[31:24]};
        unique case(mem_opReg[2:0])
            3'b101: mem_out6 = 32'(signed'(piton_out[baddr]));                            //i_lb
            3'b011: mem_out6 = 32'(signed'({piton_out[baddr + 1], piton_out[baddr]}));  //i_lh
            3'b111: mem_out6 = piton_out;	                                                //i_lw
            3'b100: mem_out6 = {24'b0, piton_out[baddr]};     	                        //i_lbu
            3'b010: mem_out6 = {16'b0, piton_out[baddr + 1], piton_out[baddr]};	        //i_lhu
            default: mem_out6 = 0;
        endcase
    end
end
endmodule

module mem_wrap(
    input logic clk, nrst,
    input logic [3:0] mem_op4,       //memory operation type
    input logic [31:0] op_a4,        //base address
    input logic [31:0] op_b4,        //src for store ops, I_imm offset for load ops
    input logic [31:0] S_imm4,       //S_imm offset
	input logic stall_mem,dmem_finished,

    //OpenPiton Request
	output logic [3:0] mem_l15_rqtype, 
	output logic [2:0] mem_l15_size,
	output logic [31:0] mem_l15_address,
	output logic [63:0] mem_l15_data,
	
    output logic mem_l15_val,

	//OpenPiton Response
	input logic [63:0] l15_mem_data_0, 
    input logic [63:0] l15_mem_data_1, 
	input logic [3:0] l15_mem_returntype,
    
    input logic l15_mem_val,
    input logic l15_mem_ack,
	input logic l15_mem_header_ack,
    output logic mem_l15_req_ack,

    output logic [31:0] mem_out6,
    output logic memOp_done,
    output logic m_op6,

    output logic ld_addr_misaligned6,
    output logic samo_addr_misaligned6
);
    logic [31:0] addr6;
    logic [31:0] data_in6; 
    logic [1:0]  baddr6;
    logic gwe6, rd6;
    logic bw06, bw16, bw26, bw36;
    logic addr_misaligned6;
    logic [3:0] mem_op6;
    
    mem_decode mem_decode (
        //inputs
    .clk                      (clk),
    .nrst                     (nrst),
    .mem_op4                  (mem_op4),    //memory operation type
    .op_a4                    (op_a4),      //base address
    .op_b4                    (op_b4),      //src for store ops, I_imm offset for load ops
    .S_imm4                   (S_imm4),     //S_imm offset
	.stall_mem			   (stall_mem),
	.dmem_finished 		   (dmem_finished),
	
        //outputs
    .addr6                    (addr6),
    .data_in6                 (data_in6),
    .baddr6                   (baddr6),
    .gwe6                     (gwe6),
    .rd6                      (m_rd6),
    .bw06                     (bw06),
    .bw16                     (bw16),
    .bw26                     (bw26),
    .bw36                     (bw36),
    .m_op6                    (m_op6),
    .addr_misaligned6         (addr_misaligned6),
    .ld_addr_misaligned6      (ld_addr_misaligned6),
    .samo_addr_misaligned6    (samo_addr_misaligned6),
    .mem_op6                 (mem_op6)
);

    piton_fsm piton_fsm(
    .clk                (clk),
    .nrst               (nrst),
    //core -> memory controls
    .addr6              (addr6),
    .data_in6           (data_in6),          //memory input data
    .m_rd6              (m_rd6),
    .bw06               (bw06),
    .bw16               (bw16),
    .bw26               (bw26),
    .bw36               (bw36),
    .m_op6              (m_op6), 
    .mem_op6            (mem_op6),

    //OpenPiton Request
	.core_l15_rqtype    (mem_l15_rqtype), 
	.core_l15_size      (mem_l15_size),
	.core_l15_address   (mem_l15_address),
	.core_l15_data      (mem_l15_data),
	
    .core_l15_val       (mem_l15_val),

	//OpenPiton Response
	.l15_core_data_0    (l15_mem_data_0), 
    .l15_core_data_1    (l15_mem_data_1), 

	.l15_core_returntype(l15_mem_returntype),
    
    .l15_core_val       (l15_mem_val),
    .l15_core_ack       (l15_mem_ack),
	.l15_core_header_ack(l15_mem_header_ack),
    .core_l15_req_ack   (mem_l15_req_ack),

    .mem_out6           (mem_out6),
    .memOp_done         (memOp_done)
);
endmodule
