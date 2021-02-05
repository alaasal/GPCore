module mul_div (
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [3:0] mulDiv_op,

    output logic [31:0] res
);

    logic [63:0] mul;
    logic [31:0] div, rem;
    logic sign_a, sign_b;

    localparam OVERFLOW_END = 32'h8000_0000;
    localparam OVERFLOW_SOR = -1;

    /*
    mulDiv_op
    mulDiv_op[3]    -> mul[h][s][u] = 0, div[u]/rem[u] = 1
    mulDiv_op[2]    -> div/mul = 0, mulh[s][u]/rem[u] = 1
    mulDiv_op[1:0]  -> signed = 1, unsigned = 3, 
    ----------------------|
    mulDiv_op | operation |
    ----------------------|
    4'b0000   | no_op     |
    4'b0011   | MUL       |
    4'b0101   | MULH      |
    4'b0111   | MULHU     |
    4'b0110   | MULHSU    |
    4'b1001   | DIV       |
    4'b1011   | DIVU      |
    4'b1101   | REM       |
    4'b1111   | REMU      |
    ----------------------|
    */ 
    always_comb begin
        sign_a = 0;
        sign_b = 0;
        case(mulDiv_op[1:0])
            1: begin        //mulh, rem
                sign_a = 1;
                sign_b = 1;
            end 2: begin    //mulhsu
                sign_a = 1;
                sign_b = 0;
            end 3, 0: begin //mul, mulhu, divu, remu, no_op
                sign_a = 0;
                sign_b = 0;
            end
        endcase
    end

    always_comb begin
        if (|mulDiv_op) begin   //(mulDiv != 0)
            if (mulDiv_op[3] == 0) begin
                mul = $signed({a[31] & sign_a, a}) * $signed({b[31] & sign_b, b});
            
                unique case(mulDiv_op[2])
                    0:  res = mul[31:0];  //mul
                    1:  res = mul[63:32]; //mulh[s][u]
                endcase

            end else begin
                if (b == 0) begin   //division by zero
                    rem = a;
                    div = 32'hffff_ffff; //(-1 -> DIV)
                end else if (a == OVERFLOW_END & b == OVERFLOW_SOR & (mulDiv_op[1:0] == 1)) begin    //overflow
                    rem = 0;
                    div = OVERFLOW_END;
                end else begin
                    rem = $signed({a[31] & sign_a, a}) % $signed({b[31] & sign_b, b});
                    div = $signed({a[31] & sign_a, a}) / $signed({b[31] & sign_b, b});;
                end
                    case(mulDiv_op[2])
                        0: res = div;
                        1: res = rem;
                    endcase
            end
        end else res = 0;
    end
endmodule 