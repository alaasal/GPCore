
module commit_stage(
    input logic clk, nrst,
    input logic we5,
    input logic [4:0] rd5,
    input logic [31:0] U_imm5,
    input logic [31:0] result5,   // input result from mem to commit stage
    input logic [31:0] pc5,
    input logic [2:0] fn5,
    input logic [31:0] mem_out6,
    input logic [31:0] mul_div5,

    output logic [4:0] rd6,
    output logic [31:0] wb_data6, // final output that will be written back in register file PIPE #6
    output logic we6
    );
logic weReg6,rdReg6;
    // output
        always_ff @(posedge clk, negedge nrst)
      begin
    if (!nrst) begin
	weReg6<=0;
	rdReg6<=0;
	end
else begin 
	weReg6<=we5;
	rdReg6<=rd5;
	end 
      end

   always_comb begin
        unique case(fn5)
            0: wb_data6  = result5;
            1: wb_data6  = pc5 + 1;
            2: wb_data6  = mul_div5;
            3: wb_data6  = U_imm5;
            4: wb_data6  = mem_out6;
            default: wb_data6 = 0;
        endcase
    end
    assign rd6 = rdReg6;
    assign we6 = weReg6;

endmodule
