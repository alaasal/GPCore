module mul_div (
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [2:0] m_op,

    output logic [31:0] res
);
    logic [63:0] mul;
    logic [31:0] div, rem;
    always_comb begin
        if (m_op[2] == 0) begin
            mul = a * b;
            
            case(m_op[1:0])
                0:  res = mul[31:0];
                1:  res = mul[63:32];
                2:  res = $signed(mul[63:32]);
                3:  res = mul[63:32];
            endcase
        end else begin
            if (a == 0) begin   //division by zero
                rem = a;
                div = 32'hffff_ffff;
            end else if (a == -(2**31) & b == 0 & (m_op[1:0] == 1 | m_op[1:0] == 3)) begin    //overflow
                rem = 0;
                div = -(2**31);
            end else begin
                rem = a % b;
                div = a / b;
            end
                case(m_op[1:0])
                    0, 1: res = div;
                    2, 3: res = rem;
                endcase
        end
    end
endmodule 