//file: data memory
//initial author: O.Younis
//source: Harris & Harris digital design and computer architecture
//about: this is a simple byte addressable data memory, excerpt form H&H book and adjusted to fit the architecture and byte addressability.

module data_mem #(
    parameter XLEN      = 32,
    parameter BC        = XLEN / 8, //byte count
    parameter BADDR     = 2,    //byte address
    parameter EADDR     = XLEN - BADDR,   //byte address
    parameter MEM_LEN   = 256
)(
    input logic clk, 
    input logic gwe, rd,
    input logic bw0, bw1, bw2, bw3,         //byte write signals
    input logic [XLEN - 1:0] addr, data_in,

    output logic [XLEN - 1: 0] data_out
);

    logic [BC - 1 : 0][7 : 0] MEM [MEM_LEN - 1: 0];

    logic [EADDR - 1: 0] waddr = addr [XLEN - 1 : BADDR];  
    logic [BADDR - 1: 0] baddr = addr [BADDR - 1: 0];       //byte addr: specifies wich byte to read write
    
    always_ff @(posedge clk) begin
        if (gwe) MEM[waddr] <= data_in;     //gwe: global write enable, write to all 32 bits
        else begin
            case (baddr)
                2'b00: begin    //half, byte
                    if (bw0) MEM[waddr][0] <= data_in[7:0];
                    if (bw1) MEM[waddr][1] <= data_in[15:8];
                end 2'b01: begin //byte only
                    if (bw1) MEM[waddr][1] <= data_in[7:0;
                end 2'b10: begin
                    if (bw2) MEM[waddr][2] <= data_in[7:0];
                    if (bw3) MEM[waddr][3] <= data_in[15:8];
                end 2'b11: begin
                    if (bw3) MEM[waddr][3] <= data_in[7:0];
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (rd) data_out <= MEM[waddr]; //word align to multiples of 4
    end
endmodule

//TODO: adjust testbench for half and byte writes
module mem_test;
    timeunit 1ns;

    parameter XLEN = 32;
    parameter MEM_LEN  = 256;

    logic clk;
    logic we, rd;
    logic [XLEN - 1:0] addr, data_in;

    logic [XLEN - 1:0] data_out;

    data_mem #(
    .XLEN        (XLEN),
    .MEM_LEN     (MEM_LEN)
    ) mem_dut (
    .clk         (clk),
    .we          (we),
    .rd          (rd),
    .addr        (addr),
    .data_in     (data_in),
    .data_out    (data_out)
    );

    initial begin
        clk     <= 0;
        we      <= 1;
        rd      <= 0;
        addr    <= 0;
        data_in <= 0;

        forever begin
            #10;
            clk <= !clk;
        end
    end

    always @(posedge clk) begin
        #8;
        we      <= 1;
        data_in <= data_in + 1;
        addr    <= addr + 4;
    end
endmodule
