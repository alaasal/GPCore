//file: data memory
//initial author: O.Younis
//source: Harris & Harris digital design and computer architecture
//about: this is a simple byte addressable data memory, excerpt form H&H book and adjusted to fit the architecture.

module data_mem #(
    parameter XLEN = 32,
    parameter MEM_LEN  = 256
)(
    input logic clk, 
    input logic we, rd,
    input logic [XLEN - 1:0] addr, data_in,

    output logic [XLEN - 1:0] data_out
);

    logic [XLEN - 1:0] MEM [MEM_LEN - 1: 0];
    
    always_ff @(posedge clk) begin
        if (we) MEM[addr[XLEN - 1: 2]] <= data_in;
        if (rd) data_out <= MEM[addr[XLEN - 1: 2]]; //word align to multiples of 4
    end
endmodule

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
