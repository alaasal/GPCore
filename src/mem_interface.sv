//description: This is a memory wrapper,
//it generates the addresses and control signals for the data memory,
//it also performs the proper extension of outputs. 

module mem_interface(
    input logic clk, nrst,
    input logic [3:0] mem_op4,             //memory operation type
    input logic [31:0] op_a4,        //base address
    input logic [31:0] op_b4,        //src for store ops, I_imm offset for load ops
    input logic [31:0] S_imm4,       //S_imm offset

    output logic [31:0] addr6,
    output logic [31:0] data_in6, 
    output logic [1:0]  baddr6,
    output logic gwe6, rd6,
    output logic bw06, bw16, bw26, bw36,
    output logic m_op6,
    output logic addr_misaligned6,
    output logic ld_addr_misaligned6,
    output logic samo_addr_misaligned6,

    input  logic [31:0] piton_out6,
    output logic [31:0] mem_out6
);
    //pipe5 registers
    logic [3:0] mem_opReg5; 
    logic m_opReg5;
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

    //pipe5 memory controls
    logic [3:0] mem_op6; 
    logic [3:0][7:0] data_out6;


    //pipe5
    always_ff @(posedge clk, negedge nrst) begin
        if (!nrst) begin
            mem_opReg5  <= 0;
            op_aReg5    <= 0;
            op_bReg5    <= 0;
            S_immReg5   <= 0;
        end else begin
            mem_opReg5  <= mem_op4;
            op_aReg5    <= op_a4;
            op_bReg5    <= op_b4;
            S_immReg5   <= S_imm4;
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
    
    assign data_in5 = op_b5; 

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
    assign m_op6                 = m_opReg5;
/*
    data_mem dmem (
    .clk        (clk),
	.nrst	(nrst),
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
    assign baddr6 = addr6[1:0];

    always_comb begin
        unique case(mem_op6[2:0])
            3'b101: mem_out6 = 32'(signed'(piton_out6[baddr6]));                            //i_lb
            3'b011: mem_out6 = 32'(signed'({piton_out6[baddr6 + 1], piton_out6[baddr6]}));  //i_lh
            3'b111: mem_out6 = piton_out6;	                                                //i_lw
            3'b100: mem_out6 = {24'b0, piton_out6[baddr6]};     	                        //i_lbu
            3'b010: mem_out6 = {16'b0, piton_out6[baddr6 + 1], piton_out6[baddr6]};	        //i_lhu
            default: mem_out6 = 0;
        endcase
    end
endmodule