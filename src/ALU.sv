module alu #(
    //arithmetic
    parameter ADD = 0, //4'b0000,
    parameter SUB = 8, //4'b1000,
    //shift
    parameter SLL = 1, //4'b0001,
    parameter SRL = 5, //4'b0101,
    parameter SRA = 13,//4'b1101
    //logical
    parameter XOR = 4, //4'b0100,
    parameter OR  = 6, //4'b0110,
    parameter AND = 7, //4'b0111,
    //comparison
    parameter BGE  = 9, //4'b1001,
    parameter BGEU = 10,//4'b1010,
    parameter SLT  = 2, //4'b0010,
    parameter SLTU = 3  //4'b0011
)(
	input  logic bneq,btype,
	input  logic [3:0]   alu_fn,
	input  logic signed [31:0]  operandA,
	input  logic signed [31:0]  operandB,

	output logic btaken,
	output logic signed [31:0]  result
);

    //TODO: move signal decoding to a seperate always block
    logic sub_op;
    logic signed [31:0] b_adder;    //operand b input to adder
    logic signed [31:0] a_adder;    //operand a input to adder
    logic signed [31:0] adder_result;      //33 adder output, bit 32 is carry out(overflow indication)
    logic [31:0] b_negate;
    logic cin, cout;                      //adder carry-in, mapped to fpga Cin
    //adder
    always_comb begin
        sub_op <= (alu_fn == SUB);

        b_negate <= sub_op;

        b_adder  <= {32{b_negate}} ^ operandB;
        cin      <= sub_op;
        a_adder  <= operandA;

        {cout ,adder_result} <= a_adder + b_adder + cin;    //output of add, sub
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
    logic slt_op, sltu_op, bge_op, bgeu_op;
    logic op_signed;
    logic [31:0] a_comp;            //comparator input a
    logic [31:0] b_comp;            //comparator input b
    logic [31:0] less_unsigned, less_signed;
    logic [31:0] comparator_result; //comparator output
    //comparator
    always_comb begin
        slt_op  <= (alu_fn == SLT);
        sltu_op <= (alu_fn == SLTU);
        bge_op  <= (alu_fn == BGE);
        bgeu_op <= (alu_fn == BGEU);

        op_signed <= slt_op & ~sltu_op & beg_op & ~bgeu_op;

        a_comp <= operandA;
        b_comp <= operandB;

        less_unsigned <= a_comp < b_comp;
        less_signed   <= $signed(a_comp) < $signed(b_comp);

        comparator result <= (op_signed)? less_signed : less_unsigned;
    end
    /***************************************************************************************************************/
    /***************************************************************************************************************/
    //result block
    always_comb begin
        case (alu_fn)
            //logical operations
            AND: result <= operandA & operandB; 
            OR:  result <= operandA | operandB;
            XOR: result <= operandA ^ operandB;
            
            //arithmetic operations
            ADD, SUB: result <= adder_result;

            //shift operations
            SLL, SRL, SRA: result <= shifter_result;
            
            //comparator operations
            SLT, SLTU, BGE, BGEU: result <= comparator_result;
            default: result <= 32'b0;
        endcase    
    end

    //branch block
    always_comb begin
        case (alu_fn)
            SUB: btaken <= ((|result) & bneq) || ((~|result) & ~bneq);
            SLT, SLTU: btaken <= result[0];
            BGE, BGEU: btaken <= ~result[0];
            default: btaken <= 0;
        endcase
    end
endmodule
/*
    //removed next commit
	always_comb
	  begin
		unique case(alu_fn)
			//4'b0000: result = $signed(operandA) + $signed(operandB);
			//4'b0001: result = $signed(operandA) << $signed(operandB);
			//4'b0010: result = ($signed(operandA) < $signed(operandB));
			//4'b0011: result = (operandA < operandB); 
			//4'b0100: result = $signed(operandA) ^ $signed(operandB);
			//4'b0101: result = $signed(operandA) >> $signed(operandB);
			//4'b0110: result = $signed(operandA) | $signed(operandB);
			//4'b0111: result = $signed(operandA) & $signed(operandB);
			//4'b1000: result = $signed(operandA) - $signed(operandB);

            //will be depricated in the next commit, will rely on 4'b0010 and 4'b0011 instead 
			//4'b1001: result = ($signed(operandA) > $signed(operandB));  // for bge 
			//4'b1010: result = (operandA > operandB);  		    // for bgeu
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


endmodule*/