module frontend_stage(
    input logic clk, 
	input logic nrst,
	input logic stall,
	
    input logic [1:0] PCSEL,		// pc select control signal
    input logic [31:0] target,
	input logic [1:0] stallnumin,

    output logic [31:0] pc2,	// pc at instruction mem pipe #2
    output logic [31:0] instr2,  	// instruction output from inst memory (to decode stage)

	output logic instruction_addr_misaligned2, // output from front_end to decode_stage

	//DEBUG Signals from debug module to load a program
    input logic DEBUG_SIG,				
    input logic [31:0] DEBUG_addr,
    input logic [31:0] DEBUG_instr,
    input logic clk_debug
    );

    // registers
	logic [31:0] pcReg; 	   // pipe #1 pc
	logic [31:0] pcReg2;	   // pipe #2 from pc to inst mem
	
	// Exceptions at forntend
	//logic instruction_addr_misalignedReg1;
	logic instruction_addr_misalignedReg2;
	// Exception pending
	logic pcsel_interrupt;
	logic [31:0] mtvec_out;
	logic flag_ex;
	
	
    // wires
    logic [31:0] npc;   	   // next pc wire
    logic [31:0] pc;

	assign pc_addr_ex = 0; // will be replaced by the exceptions generation logic 
    

    // pipes

    always_ff @(posedge clk , negedge nrst)
	begin
        if (!nrst)
        begin
		pcReg		<= 0;
		pcReg2 		<= 0;
		
		pcsel_interrupt	<= 0;
		flag_ex	<= 0;
		
		//instruction_addr_misalignedReg1 <= 0;
		instruction_addr_misalignedReg2 <= 0;

		end
		// Interrupt
		else if (pcsel_interrupt && (!flag_ex)) 
		begin
			pcReg <= mtvec_out;
			flag_ex <= 1;
		end
		
        else begin	
	//stallnumin<=stallnuminin;
	if ( stall&&!stallnumin[1] && !stallnumin[0]) begin 
		pcReg		<= pcReg-1;		
		pcReg2		<= pcReg2-1;

	////////////////////////////////////////////////////////////
	//instruction_addr_misalignedReg1 <= 0;
		instruction_addr_misalignedReg2 <= instruction_addr_misalignedReg2;
	////////////////////////////////////////////////////////////

	end
	else if(stall && !(!stallnumin[1] && stallnumin[0]) ) 
	begin 
		pcReg		<= pcReg;		
		pcReg2		<= pcReg2;

		////////////////////////////////
		//instruction_addr_misalignedReg1 <= 0;
		instruction_addr_misalignedReg2 <= instruction_addr_misalignedReg2;

		/////////////////////////////////

	end 
	else if(stall &&!stallnumin[1] && stallnumin[0] )
	begin 
		pcReg		<= npc;		
		pcReg2		<= pcReg;

	////////////////////////////////////////////////
		//instruction_addr_misalignedReg1 <= 0;
		instruction_addr_misalignedReg2 <= instruction_addr_misalignedReg2;
	////////////////////////////////////////////////	


	end 
	else if(stall ) 
	begin 
		pcReg		<= pcReg;		
		pcReg2		<= pcReg2;

	/////////////////////////////////////////////
		//instruction_addr_misalignedReg1 <= 0;
		instruction_addr_misalignedReg2 <= instruction_addr_misalignedReg2;
	//////////////////////////////////////////////

	end 
	else 
	begin 
		pcReg		<= npc;		// PIPE1
		pcReg2		<= pcReg;
		
		//instruction_addr_misalignedReg1 <= pc_addr_ex;
		instruction_addr_misalignedReg2 <= pc_addr_ex;
		// Exceptions logic here
	end

	end 

	end 

    always_comb
      begin
        // npc logic
        unique case({pcsel_interrupt, PCSEL})
            3'b000: npc = pcReg + 1;
            3'b001: npc = 0;
            3'b010: npc = target;
            3'b011: npc = npc;
			//Exception

			3'b100,3'b101,3'b110,3'b111: npc = pcReg + 1;

            default: npc = pcReg + 1 ;
        endcase
        
      end
	  
	  

    // output

	assign pc = (stall && !stallnumin[1] && !stallnumin[0]) ? pcReg-1: pcReg;
	assign pc2 = (stall && !stallnumin[1] && !stallnumin[0]) ? pcReg2 - 1 : pcReg2;
	
	assign instruction_addr_misaligned = instruction_addr_misalignedReg2;
	
	// =============================================== //
	//			CSR_REGFILE		   //
	// =============================================== //
	csr_regfile csr(
	.pcsel_interrupt (pcsel_interrupt),
	.mtvec_out (mtvec_out)
	);

    // dummy inst mem
    instr_mem m1 (
	.clk(clk ),
	.addr(pc),
	.instr(instr2), 		
	.DEBUG_SIG(DEBUG_SIG),				//DEBUG Signals from debug module to load a program
	.DEBUG_addr(DEBUG_addr),
	.DEBUG_instr(DEBUG_instr),
	.clk_debug(clk_debug)
	); 

endmodule