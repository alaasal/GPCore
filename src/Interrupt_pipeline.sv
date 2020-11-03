module interrupt_pipeline(
	input logic clk,
	input logic nrst,
	
	input logic [31:0] pc,
	
	// Exceptions 
	input logic pc_address_ex,
	input logic decode_ex,
	input logic alu_ex,
	input logic data_mem_ex,
	input logic asynchronous_ex,		// External Exceptions
	
	output logic interrupt_taken,		// Kills instructions in the pipeline / Reset interrupt pipeline / Input to CSR 
	
	output logic [4:0] cause,
	output logic [31:0] epc
	);
	
	// Exceptions pipeline
	logic  ex_D;
	logic  [1:0] ex_E;
	logic  [2:0] ex_M;
	
	// PC pipeline
	logic [31:0] pc_D;
	logic [31:0] pc_E;
	logic [31:0] pc_M;
	
	// output reg
	logic interrupt_taken_reg;
	
	logic [4:0] cause_reg;
	logic [31:0] epc_reg;
	
	
	always_ff @(posedge clk , negedge nrst)
	begin
        if (!nrst)
        begin
			// reset
			ex_D		<= 0;
			ex_E 		<= 0;
			ex_M 		<= 0;
		
			pc_D		<= 0;
			pc_E		<= 0;
			pc_M		<= 0;
			
			interrupt_taken_reg <= 0;
			
			cause_reg	<= 0;
			epc_reg		<= 0;
		
		end
		
        else if(interrupt_taken_reg	== 1)
		begin
			// interrupt is taken
			
			
			// reset
			ex_D		<= 0;
			ex_E 		<= 0;
			ex_M 		<= 0;
		
			pc_D		<= 0;
			pc_E		<= 0;
			pc_M		<= 0;
				
				
		end
		
		else
		begin
			// pipeline
			ex_D		<= pc_address_ex;
			ex_E 		<= {decode_ex , ex_D};
			ex_M 		<= {alu_ex , ex_E};
			
			
		
			pc_D		<= pc;
			pc_E		<= pc_D;
			pc_M		<= pc_E;
			
			
			// check for interrupt
			if ((asynchronous_ex || data_mem_ex || ex_M) == 1)
			begin
				interrupt_taken_reg	<= 1;
				// cause
				cause_reg	<= {ex_M , data_mem_ex , asynchronous_ex};		// The Lower the bit means the higher priority
				// pc
				epc_reg		<= pc_M;
			end

		end
	
	end
	
	
	assign cause  = cause_reg;
	assign epc  = epc_reg;		
	assign interrupt_taken = interrupt_taken_reg;
	
	
	
endmodule