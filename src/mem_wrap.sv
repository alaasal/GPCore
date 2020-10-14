//description: This is a memory wrapper,
//it generates the addresses and control signals for the data memory,
//it also performs the proper extension of outputs. 

module mem_wrap(
    input logic clk, nrst,
    input logic [3:0] mem_op4,             //memory operation type
    input logic [31:0] op_a4,        //base address
    input logic [31:0] op_b4,        //src for store ops, I_imm offset for load ops
    input logic [31:0] S_imm4,       //S_imm offset

    output logic [31: 0] mem_out6,
    output logic addr_misaligned6
);
    //pipe5 registers
    logic [3:0] mem_opReg5; 
    logic [31:0] op_aReg5, op_bReg5, S_immReg5;

    //pipe5 outputs
    logic [3:0]mem_op5;
    logic [31:0] op_a5, op_b5, S_imm5;

    //pipe5 memory controls
    logic gwe5, rd5; 
    logic [31:0] addr5, data_in5;
    logic [1:0] addr_mis5;
    logic addr_misaligned5;
    logic bw05, bw15, bw25, bw35;

    //pip6 registers
    logic gweReg6, rdReg6;
    logic [3:0] mem_opReg6;
    logic [31:0] addrReg6, data_inReg6;
    logic addr_misalignedReg6;
    logic bw0Reg6, bw1Reg6, bw2Reg6, bw3Reg6;

    //pipe5 memory controls
    logic gwe6, rd6;
    logic [3:0] mem_op6; 
    logic [31:0] addr6, data_in6;
    logic [3:0][7:0] data_out6;
    logic bw06, bw16, bw26, bw36;
    logic [1:0] baddr6;

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
            gweReg6             <= 0;
            rdReg6              <= 0;
            mem_opReg6          <= 0;
            addrReg6            <= 0;
            data_inReg6         <= 0;
            addr_misalignedReg6 <= 0;
            bw0Reg6             <= 0; 
            bw1Reg6             <= 0; 
            bw2Reg6             <= 0; 
            bw3Reg6             <= 0;
        end else begin
            gweReg6             <= gwe5;
            rdReg6              <= rd5;
            mem_opReg6          <= mem_op5;
            addrReg6            <= addr5;
            data_inReg6         <= data_in5;
            addr_misalignedReg6 <= addr_misaligned5;
            bw0Reg6             <= bw05; 
            bw1Reg6             <= bw15; 
            bw2Reg6             <= bw25; 
            bw3Reg6             <= bw35;
        end
    end

    assign mem_op5  = mem_opReg5;
    assign op_a5    = op_aReg5;
    assign op_b5    = op_bReg5;
    assign S_imm5   = S_immReg5;

    //mem_op
    //4'b0000	//no memory operation
    //4'b0001   //i_lb
    //4'b0010	//i_lh
    //4'b0011	//i_lw
    //4'b0100	//i_lbu
    //4'b0101	//i_lhu
    //4'b1110	//i_sb
    //4'b1111	//i_sh
    //4'b1000   //i_sw

                              //s imm + offset   //i imm + offset  
    assign addr5    = (mem_op5[3])? (S_imm5 + op_a5) : (op_b5 + op_a5);
    
    //reconstruct instructions
    assign i_lb  = (mem_op5 == 1);
    assign i_lh  = (mem_op5 == 2);
    assign i_lw  = (mem_op5 == 3);
    assign i_lbu = (mem_op5 == 4);
    assign i_lhu = (mem_op5 == 5);
    assign i_sb  = (mem_op5 == 14);
    assign i_sh  = (mem_op5 == 15);
    assign i_sw  = (mem_op5 == 8);
    
    //generate address misaligned exception
    assign addr_mis5[0] = (i_lh | i_lhu | i_sh | i_sw) & addr5[0];
    assign addr_mis5[1] = (i_lw | i_sw) & addr5[1];
    assign addr_misaligned5 = addr_mis5[0] | addr_mis5[1];

    assign gwe5 = (mem_op5[3] & ~(mem_op5[2] | mem_op5[1] | mem_op5[0])) & ~addr_misaligned5;
    assign rd5  = !mem_op5[3] & (mem_op5[0] | mem_op5[1] | mem_op5[2]) & ~addr_misaligned5;

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
    assign bw05 = (~addr5[1]  & ~addr5[0]) & (i_sb | i_sh) & ~addr_misaligned5;
    assign bw25 = (addr5[1]   & ~addr5[0]) & (i_sb | i_sh) & ~addr_misaligned5;
    assign bw15 = ~addr5[1]   & ((addr5[0] & i_sb)  | (~addr5[0] & i_sh)) & ~addr_misaligned5; 
    assign bw35 = addr5[1]    & ((addr5[0] & i_sb)  | (~addr5[0] & i_sh)) & ~addr_misaligned5;
    
    assign data_in5 = op_b5; 

    assign gwe6             = gweReg6;
    assign rd6              = rdReg6;
    assign mem_op6          = mem_opReg6;
    assign addr6            = addrReg6;
    assign data_in6         = data_inReg6;
    assign addr_misaligned6 = addr_misalignedReg6;
    assign bw06             = bw0Reg6;
    assign bw16             = bw1Reg6;
    assign bw26             = bw2Reg6;
    assign bw36             = bw3Reg6;

    data_mem dmem (
    .clk        (clk),
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

    assign baddr6 = addr6[1:0];

    always_comb begin
        unique case(mem_op6)
            4'b0001: mem_out6 = 32'(signed'(data_out6[baddr6]));             //i_lb
            4'b0010: mem_out6 = 32'(signed'({data_out6[baddr6 + 1], data_out6[baddr6]}));	//i_lh
            4'b0011: mem_out6 = data_out6;	                                //i_lw
            4'b0100: mem_out6 = {24'b0, data_out6[baddr6]};     	            //i_lbu
            4'b0101: mem_out6 = {16'b0, data_out6[baddr6 + 1], data_out6[baddr6]};	    //i_lhu
            default: mem_out6 = 0;
        endcase
    end
endmodule