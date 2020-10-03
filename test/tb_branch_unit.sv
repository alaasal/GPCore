module tb_branch_unit;
reg [31:0]   pc; 
reg  [31:0]  B_imm;  
reg   btaken;		  
wire [31:0]  b_target;

// instantiate device under test
 branch_unit dut(.pc(pc), .B_imm(B_imm), .btaken(btaken), .b_target(b_target));

 initial 
	begin 
	 #20 btaken <= 1'b 1 ; //b_target=32'h 42426666
	 pc <= 32'h 33333333 ;        
         B_imm <= 32'h 0f0f3333;
	 #40 btaken <= 1'b 0 ; //b_target=32'h 33333334
	 pc <= 32'h 33333333 ;        
         B_imm <= 32'h 0f0f3333;
	end 
  
 
endmodule
