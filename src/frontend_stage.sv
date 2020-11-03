module frontend_stage(
    input logic clk, 
	input logic nrst,
	input logic stall,
	
	input logic [1:0] PCSEL,		// pc select control signal
	input logic [31:0] target,
	input logic [1:0] stallnumin,

	output logic [31:0] pc2,	// pc at instruction mem pipe #2
	output logic [31:0] instr2,  	// instruction output from inst memory (to decode stage)
    
 

	//DEBUG Signals from debug module to load a program
	input logic DEBUG_SIG,				
	input logic [31:0] DEBUG_addr,
	input logic [31:0] DEBUG_instr,
	input logic clk_debug
    );

    // registers
	logic [31:0] pcReg; 	   // pipe #1 pc
	logic [31:0] pcReg2;	   // pipe #2 from pc to inst mem

    // wires
    logic [31:0] npc;   	   // next pc wire
    logic [31:0] pc; 
    

    // pipes

    always_ff @(posedge clk , negedge nrst)
	begin
        if (!nrst)
        begin
		pcReg		<= 0;
		pcReg2 		<= 0;

		end
        else begin	
	//stallnumin<=stallnuminin;
	if ( stall&&!stallnumin[1] && !stallnumin[0]) begin 
		pcReg		<= pcReg-1;		
		pcReg2		<= pcReg2-1;
	end
	else if(stall && !(!stallnumin[1] && stallnumin[0]) ) 
	begin 
		pcReg		<= pcReg;		
		pcReg2		<= pcReg2;
	end 
	else if(stall &&!stallnumin[1] && stallnumin[0] )
	begin 
		pcReg		<= npc;		
		pcReg2		<= pcReg;
	end 
	else if(stall ) 
	begin 
		pcReg		<= pcReg;		
		pcReg2		<= pcReg2;
	end 
	else 
	begin 
		pcReg		<= npc;		// PIPE1
		pcReg2		<= pcReg;
	end

	end 

	end 

    always_comb
      begin
        // npc logic
        unique case(PCSEL)
            0: npc = pcReg + 1;
            1: npc = 0;
            2: npc = target;
            3: npc = npc;
            default: npc = pcReg + 1 ;
        endcase
        
      end

    // output

	assign pc = (stall && !stallnumin[1] && !stallnumin[0]) ? pcReg-1: pcReg;
	assign pc2 = (stall && !stallnumin[1] && !stallnumin[0]) ? pcReg2 - 1 : pcReg2;
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
