module ROM_key
#(
    parameter addr_width = 32, // store 32 elements
              addr_bits = 5, // required bits to store 32 elements
              data_width = 128 // each element has 128-bits
)
(
    input wire clk, en,
    input wire [addr_bits-1:0] addr,
    output wire [data_width-1:0] dout
);

(*rom_style = "block" *) reg [data_width-1:0] data; // to be synthesized as BRAM in FPGA

always @(posedge clk)
begin
  if (en)
    begin
    case(addr)
        5'd0 : data = 128'hf69f2445df4f9b17ad2b417be66c3710;
        5'd1 : data = 128'h6bc1bee22e409f96e93d7e117393172a;
        5'd2 : data = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        5'd3 : data = 128'hf69f2445df4f9b17ad2b417be66c3710;
        5'd4 : data = 128'h603deb1015ca71be2b73aef0857d7781; 
        5'd5 : data = 128'h1f352c073b6108d72d9810a30914dff4;
        5'd6 : data = 128'h7b0c785e27e8ad3f8223207104725dd4;
        5'd7 : data = 128'h6bc1bee22e409f96e93d7e117393172a;
        5'd8 : data = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        5'd9 : data = 128'hf69f2445df4f9b17ad2b417be66c3710;
        5'd10 : data = 128'h603deb1015ca71be2b73aef0857d7781; 
        5'd11 : data = 128'h1f352c073b6108d72d9810a30914dff4;
        5'd12 : data = 128'h7b0c785e27e8ad3f8223207104725dd4;
        5'd13 : data = 128'h6bc1bee22e409f96e93d7e117393172a;
        5'd14 : data = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        5'd15 : data = 128'hf69f2445df4f9b17ad2b417be66c3710;
        5'd16 : data = 128'h603deb1015ca71be2b73aef0857d7781; 
        5'd17 : data = 128'h1f352c073b6108d72d9810a30914dff4;
        5'd18 : data = 128'h7b0c785e27e8ad3f8223207104725dd4;
        5'd19 : data = 128'h6bc1bee22e409f96e93d7e117393172a;
        5'd20 : data = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        5'd21 : data = 128'hf69f2445df4f9b17ad2b417be66c3710;
        5'd22 : data = 128'h603deb1015ca71be2b73aef0857d7781; 
        5'd23 : data = 128'h1f352c073b6108d72d9810a30914dff4;
        5'd24 : data = 128'h7b0c785e27e8ad3f8223207104725dd4;
        5'd25 : data = 128'h6bc1bee22e409f96e93d7e117393172a;
        5'd26 : data = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        5'd27 : data = 128'hf69f2445df4f9b17ad2b417be66c3710;
        5'd28 : data = 128'h603deb1015ca71be2b73aef0857d7781; 
        5'd29 : data = 128'h1f352c073b6108d72d9810a30914dff4;
        5'd30 : data = 128'h7b0c785e27e8ad3f8223207104725dd4;
        5'd31 : data = 128'h6bc1bee22e409f96e93d7e117393172a;
        default : data = 128'h7b0c785e27e8ad3f8223207104725dd4;
    endcase 
  end
  else
    data = 128'h0;
end

assign dout = data;

endmodule 
