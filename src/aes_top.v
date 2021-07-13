module top_aes 
#(parameter aes_len    = 128,
            addr_width = 5)
(
  input wire clk, nrst, start,
  input wire [addr_width-1:0] key_addr,
  input wire [aes_len-1:0] plaintext,
  output wire [aes_len-1:0] result,
  output wire done
);

  wire init, next, ready, result_valid, en_data, en_key;
  wire [aes_len-1:0] key;

  ctrl aes_ctrl (
    .clk(clk),
    .nrst(nrst),
    .ready(ready),
    .valid(result_valid),
    .start(start),
    .init(init),
    .next(next),
    .en_data(en_data),
    .done(done),
    .en_key(en_key)
  );
  

  reg [aes_len-1:0] plaintext_piped;

  always @(posedge clk, negedge nrst)
    begin
      if(!nrst)
        plaintext_piped <= 0;
      else
        begin
          if (en_data)
            plaintext_piped <= plaintext;
          else
            plaintext_piped <= plaintext_piped;
        end
    end

  ROM_key rom(
    .clk(clk),
    .en(en_key),
    .addr(key_addr),
    .dout(key)
  );

  aes_core aes(
    .clk(clk),
    .reset_n(nrst),
    .encdec(0), // 0 to enc
    .init(init),
    .next(next),
    .ready(ready),
    .key({key,128'b0}),
    .keylen(0),  // 0 to 128 bits
    .block(plaintext_piped),
    .result(result),
    .result_valid(result_valid)
    ); 
    
endmodule
