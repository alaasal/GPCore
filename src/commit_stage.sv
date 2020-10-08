
module commit_stage(
    input logic clk, nrst,
    input logic we5,
    input logic [4:0] rd5,
    input logic [31:0] result5,   // input result from alu to commit stage
    input logic [31:0] pc5,
    input logic [2:0] fn5,

    output logic [4:0] rd6,
    output logic [31:0] wb_data6, // final output that will be written back in register file PIPE #6
    output logic we6
    );

    // output
    always_comb begin
        unique case(fn5)
            0: wb_data6  = result5;
            1: wb_data6  = pc5;
            2: wb_data6  = 0;   //to be adjusted when m_extension is added
            3: wb_data6  = 0;   //to be adjusted with lui
            4: wb_data6  = 0;   //to be adjusted with load/store addition
            default: wb_data6 = 0;
        endcase
    end

    assign rd6 = rd5;
    assign we6 = we5;

endmodule
