module ctrl (
  input wire clk, nrst, ready, valid, start,
  output reg init, next, en_data, done, en_key
);

  localparam [2:0] wait_start  = 3'b000,
                   ld_key      = 3'b001,
                   wait_key    = 3'b010,
                   ld_text     = 3'b011,
                   wait_cipher = 3'b100;

  reg [2:0] current_state, next_state;
  
  always @(posedge clk, negedge nrst)
    if (!nrst)
      current_state <= wait_start;
    else
      current_state <= next_state;
  
  
  always @(*)
    begin
    next_state = current_state;
    init    = 0;
    next    = 0;
    en_data = 0;
    en_key  = 0;
    done    = 0;
    case (current_state)
      wait_start:
        begin
          init      = 0;
          next      = 0;
          en_data   = 0;
          if (start)
            begin
              en_key = 1;
              next_state = ld_key;
            end
        end
      ld_key:
        begin
          init   = 1;
          next   = 0;
          en_key = 0 ;
          next_state = wait_key;
        end
      wait_key:
        begin
          init      = 0;
          next      = 0;
          en_data   = 0;
          if (ready == 1)
            begin
              next_state = ld_text;
              en_data = 1;
            end
        end
      ld_text:
        begin
          init    = 0;
          next    = 1;
          next_state = wait_cipher;
        end
      wait_cipher:
        begin
          init    = 0;
          next    = 0;
          en_data = 0;
          if (valid == 1)
            begin
              done = 1;
              next_state = wait_start;
            end
        end 
      default: next_state = wait_start;
    endcase
end
endmodule
