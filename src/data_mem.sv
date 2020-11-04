//file: data memory
//initial author: O.Younis
//source: Harris & Harris digital design and computer architecture
//about: this is a simple byte addressable data memory, excerpt form H&H book and adjusted to fit the architecture and byte addressability.

module data_mem #(
    parameter XLEN      = 32,
    parameter BC        = XLEN / 8, //byte count
    parameter BADDR     = 2,    //byte address
    parameter EADDR     = XLEN - BADDR,   //byte address
    parameter MEM_LEN   = 'hffffffff
)(
    input logic clk,nrst, 
    input logic gwe, rd,
    input logic bw0, bw1, bw2, bw3,         //byte write signals
    input logic [XLEN - 1:0] addr, data_in,

    output logic [XLEN - 1: 0] data_out
);

    logic [BC - 1 : 0][7 : 0] MEM [MEM_LEN - 1: 0];

    logic [EADDR - 1: 0] waddr;  
    logic [BADDR - 1: 0] baddr;       //byte addr: specifies wich byte to read write
    
    assign waddr = addr [XLEN - 1 : BADDR];
    assign baddr = addr [BADDR - 1: 0];
    always_ff @(negedge clk) begin
        if (gwe) MEM[waddr] <= data_in;     //gwe: global write enable, write to all 32 bits
        else begin
            case (baddr)
                2'b00: begin    //half, byte
                    if (bw0) MEM[waddr][0] <= data_in[7:0];
                    if (bw1) MEM[waddr][1] <= data_in[15:8];
                end 2'b01: begin //byte only
                    if (bw1) MEM[waddr][1] <= data_in[7:0];
                end 2'b10: begin
                    if (bw2) MEM[waddr][2] <= data_in[7:0];
                    if (bw3) MEM[waddr][3] <= data_in[15:8];
                end 2'b11: begin
                	if (bw3) MEM[waddr][3] <= data_in[7:0];
                end	
            endcase
        end
    end

    always_ff @(negedge clk, nrst) 
	begin
	if (!nrst) data_out <= 0;
        if (rd) data_out <={ MEM[waddr][3],MEM[waddr][2],MEM[waddr][1],MEM[waddr][0]}; //word align to multiples of 4
    end

    always_ff @(negedge clk, nrst) 
begin
	for (int i=0;i<MEM_LEN;i=i+1) begin 
		for(int j=0;j<4;j=j+1)begin
			MEM[i][j]=8'b0;
		end
	end
    end
endmodule

