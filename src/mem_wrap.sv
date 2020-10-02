//description: This is a memory wrapper,
//it generates the addresses and control signals for the data memory,
//it also performs the proper extension of outputs. 

module mem_wrap(
    input logic clk, nrst,
    input logic mem_op4,             //memory operation type
    input logic [31:0] op_a4,        //base address
    input logic [31:0] op_b4,        //src for store ops, I_imm offset for load ops
    input logic [31:0] S_imm4,       //S_imm offset

    output logic [31: 0] mem_out
);
    //pipe5 registers
    logic mem_opReg5; 
    logic [31:0] op_aReg5, op_bReg5, S_immReg5;

    //pipe5 outputs
    logic mem_op5;
    logic [31:0] op_a5, op_b5, S_imm5;

    //pipe5 memory controls
    logic we5, rd5; 
    logic [31:0] addr5, data_in5;

    //pip6 registers
    logic weReg6, rdReg6;
    logic [3:0] mem_opReg6;
    logic [31:0] addrReg6, data_inReg6;

    //pipe5 memory controls
    logic we6, rd6;
    logic [3:0] mem_op6; 
    logic [31:0] addr6, data_in6, data_out6;

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
            weReg6      <= 0;
            rdReg6      <= 0;
            mem_opReg6  <= 0;
            addrReg6    <= 0;
            data_inReg6 <= 0;
        end else begin
            weReg6      <= we5;
            rdReg6      <= rd5;
            mem_opReg6  <= mem_op5;
            addrReg6    <= addr5;
            data_inReg6 <= data_in5;
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

    assign we5 = mem_op5[3];
    assign rd5 = !mem_op5[3] & !(!mem_op5[0] & !mem_op5[1] & !mem_op5[2]);

                              //s imm + offset   //i imm + offset  
    assign addr5    = (we5)? (S_imm5 + op_a5) : (op_b5 + op_a5);
    assign data_in5 = op_b5;    //TODO: implement byte addressability 

    assign we6      = weReg6;
    assign rd6      = rdReg6;
    assign mem_op6  = mem_opReg6;
    assign addr6    = addrReg6;
    assign data_in6 = data_inReg6;

    data_mem #(
    .XLEN        (32),
    .MEM_LEN     (256)
    ) dmem (
    .clk         (clk),
    .we          (we6),
    .rd          (rd6),
    .addr        (addr6),
    .data_in     (data_in6),
    .data_out    (data_out6)
    );

    always_comb begin
        case(mem_op6)
            4'b0001: mem_out = 32'(signed'(data_out6[7:0]));    //i_lb
            4'b0010: mem_out = 32'(signed'(data_out6[15:0]));	//i_lh
            4'b0011: mem_out = data_out;	                    //i_lw
            4'b0100: mem_out = {24'b0, data_out6[7:0]};     	//i_lbu
            4'b0101: mem_out = {16'b0, data_out6[15:0]};	    //i_lhu
            default: mem-out = 0;
        endcase
    end
endmodule