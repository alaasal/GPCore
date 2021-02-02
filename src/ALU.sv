module alu(
	input  logic bneq,btype,
	input  logic [3:0]   alu_fn,
	input  logic [31:0]  operandA,
	input  logic [31:0]  operandB,

	output logic btaken,
	output logic [31:0]  result

);

	
	always_comb
	  begin
		unique case(alu_fn)
			4'b0000: result = $signed(operandA) + $signed(operandB);
			4'b0001: result = $signed(operandA) << $signed(operandB[4:0]);
			4'b0010: result = ($signed(operandA) < $signed(operandB));
			4'b0011: result = (operandA < operandB); 
			4'b0100: result = $signed(operandA) ^ $signed(operandB);
			4'b0101: result = $signed(operandA) >> $signed(operandB[4:0]);
			4'b0110: result = $signed(operandA) | $signed(operandB);
			4'b0111: result = $signed(operandA) & $signed(operandB);
			4'b1000: result = $signed(operandA) - $signed(operandB);
			4'b1001: result = ($signed(operandA) > $signed(operandB));  // for bge 
			4'b1010: result = (operandA > operandB);  		    // for bgeu
			//5'b01011: result = 0;
			//5'b01100: result = 0;
			4'b1101: result = $signed(operandA) >>> $signed(operandB[4:0]);
			
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



