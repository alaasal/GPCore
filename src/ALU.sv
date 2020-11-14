module alu #parameter(
    //arithmetic
    ADD = 4'b0000,
    SUB = 4'b1000,
    //shift
    SLL = 4'b0001,
    SRL = 4'b0101,
    SRA = 4'b1101
    //logical
    XOR = 4'b0100,
    OR  = 4'b0110,
    AND = 4'b0111,
    //comparison
    BGE,
    BGEU,
    SLT =,
    SLTU = 

)(
	input  logic bneq,btype,
	input  logic [3:0]   alu_fn,
	input  logic signed [31:0]  operandA,
	input  logic signed [31:0]  operandB,

	output logic btaken,
	output logic signed [31:0]  result

);

    logic sub_op, xor_op;
    logic signed [31:0] b_adder;    //operand b input to adder
    logic signed [31:0] a_adder;    //operand a input to adder
    logic signed [31:0] adder_result;      //33 adder output, bit 32 is carry out(overflow indication)
    logic [31:0] b_negate;
    logic cin, cout;                      //adder carry-in, mapped to fpga Cin
    
    //adder
    //ADD, SUB, XOR
    always_comb begin
        sub_op <= (alu_fn == SUB);
        xor_op <= (alu_fn == XOR);

        if (sub_op | xor_op) b_negate <= 32'bffff_ffff;
        else b_negate <= 32'b0;

        b_adder      <= b_negate ^ operandB;
        cin          <= sub_op;
        a_adder      <= (xor_op)? 32'b0 : operandA;

        {cout ,adder_result} <= a_adder + b_adder + cin;    //output of add, sub, xor
    end
    /***************************************************************************************************************/
    /***************************************************************************************************************/
    logic sll_op, srl_op, sra_op;           //shift operations
    logic signed [31:0] shift_op_a;         //shift operand a
    logic [31:0] a_reversed;                //operand a bit reversed
    logic [31:0] shift_amt;                 //shift amount
    logic [31:0] shift_l, shift_a;          //shift logical, shift arithmetic outputs
    logic [31:0] shift_reversed;            //bit reverse shift logical output
    logic signed [31:0] shift_l_res;        //logical shifter result
    logic signed [31:0] shifter_result;     //final shifter result
    
    //shifter
    always_comb begin
        sll_op <= (alu_fn == SLL);
        srl_op <= (alu_fn == SRL);
        sra_op <= (alu_fn == SRA);

        a_reversed     <= {<<{operandA}};    //reverse operand a
        shift_op_a     <= (sll_op)? a_reversed : operandA;
        shift_amt      <= operandB;
        
        shift_l        <= shift_op_a >> shift_amt;
        shift_a        <= shift_op_a >>> shift_amt;
        shift_reversed <= {<<{shift_l}};

        shift_l_res    <= (sll_op)? shift_reversed : shift_l;
        shifter_result <= (sra_op)? shift_a : shift_l_result;   //final output
    end
    /***************************************************************************************************************/
    /***************************************************************************************************************/
    //result block
    always_comb begin
        unique case (alu_fn)
            //logical operations
            AND: result <= operandA & operandB; 
            OR:  result <= operandA | operandB;
            XOR: result <= adder_result;
            
            //arithmetic operations
            ADD, SUB: result <= adder_result;

            //shift operations
            SLL, SRL, SRA: result <= shifter_result;
            

            default: result <= 32'b0;
        endcase    
    end

	always_comb
	  begin
		unique case(alu_fn)
			//4'b0000: result = $signed(operandA) + $signed(operandB);
			//4'b0001: result = $signed(operandA) << $signed(operandB);
			4'b0010: result = ($signed(operandA) < $signed(operandB));
			4'b0011: result = (operandA < operandB); 
			//4'b0100: result = $signed(operandA) ^ $signed(operandB);
			//4'b0101: result = $signed(operandA) >> $signed(operandB);
			//4'b0110: result = $signed(operandA) | $signed(operandB);
			//4'b0111: result = $signed(operandA) & $signed(operandB);
			//4'b1000: result = $signed(operandA) - $signed(operandB);

            //will be depricated in the next commit, will rely on 4'b0010 and 4'b0011 instead 
			4'b1001: result = ($signed(operandA) > $signed(operandB));  // for bge 
			4'b1010: result = (operandA > operandB);  		    // for bgeu
			//5'b01011: result = 0;
			//5'b01100: result = 0;
			//4'b1101: result = $signed(operandA) >>> $signed(operandB);
			
			default: result = 0;
		endcase

		if (btype)
			begin 
				unique case(alu_fn)
				4'b1000: 	
						begin 
					if(bneq)  btaken =  |result ? 1'b1 : 1'b0 ; // result not equal 0 bne 
					else      btaken = ~|result ? 1'b1 : 1'b0 ; // result equal 0 beq 
						end 
				4'b0010: 	  btaken =  |result ? 1'b1 : 1'b0 ; // blt
				4'b0011: 	  btaken =  |result ? 1'b1 : 1'b0 ; // bltu
				4'b1001: 	  btaken =  |result ? 1'b1 : 1'b0 ; // bge
				4'b1010: 	  btaken =  |result ? 1'b1 : 1'b0 ; // bgeu

					default:  btaken = 0;
				endcase
			end 
		else btaken =0;
	  end


endmodule



