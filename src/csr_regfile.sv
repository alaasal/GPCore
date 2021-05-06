`define XLEN 32

// Machine-Mode
`define CSR_MVENDORID   12'hf11	//Machine Vendor ID Register (mvendorid) [p18]
`define CSR_MARCHID     12'hf12	//Machine Architecture ID Register (marchid)  [p18]
`define CSR_MIMPID      12'hf13	//Machine Implementation ID Register (mimpid) p[19]
`define CSR_MHARTID     12'hf14	//Hart ID Register (mhartid) p[19]
`define CSR_MSTATUS     12'h300	//Machine Status Registers (mstatus and mstatush) p[20]
`define CSR_MISA        12'h301	//Machine ISA Register (misa) [p15]
`define CSR_MEDELEG     12'h302	//Machine Trap Delegation Registers (medeleg and mideleg p[29]
`define CSR_MIDELEG     12'h303	//Machine Trap Delegation Registers (medeleg and mideleg p[29]
`define CSR_MIE         12'h304	//Machine Interrupt Registers (mip and mie) p[31]
`define CSR_MTVEC       12'h305	//Machine Trap-Vector Base-Address Register (mtvec) p[28]
`define CSR_MCOUNTEREN  12'h306
`define CSR_MSCRATCH    12'h340
`define CSR_MEPC        12'h341
`define CSR_MCAUSE      12'h342
`define CSR_MTVAL       12'h343
`define CSR_MIP         12'h344	//Machine Interrupt Registers (mip and mie) p[31]
`define CSR_MCYCLE      12'hb00	//**Hardware Performance Monitor p[35]
`define CSR_MINSTRET    12'hb02	//**Hardware Performance Monitor p[35]
`define CSR_MCYCLEH     12'hb80
`define CSR_MINSTRETH   12'hb82
`define CSR_CYCLEH      12'hc80
`define CSR_TIMEH       12'hc81	//**Machine Timer Registers (mtime and mtimecmp) p[33]
`define CSR_INSTRETH    12'hc82
`define CSR_MNECYCLE    12'hbbf

// User-Mode
`define CSR_USTATUS     12'h000
`define CSR_FFLAGS      12'h001
`define CSR_FRM         12'h002
`define CSR_FCSR        12'h003
`define CSR_UIE         12'h004
`define CSR_UTVEC       12'h005
`define CSR_USCRATCH    12'h040
`define CSR_UEPC        12'h041
`define CSR_UCAUSE      12'h042
`define CSR_UTVAL       12'h043
`define CSR_UIP         12'h044 
`define CSR_CYCLE       12'hc00 // cycle used
`define CSR_TIME        12'hc01 // timer used
`define CSR_INSTRET     12'hc02
`define CSR_UNECYCLE    12'h8ff

// Superviser-Mode
`define CSR_SSTATUS     12'h100
`define CSR_SEDELEG     12'h102
`define CSR_SIDELEG     12'h103
`define CSR_SIE         12'h104
`define CSR_STVEC       12'h105
`define CSR_SCOUNTEREN  12'h106
`define CSR_SSCRATCH    12'h140
`define CSR_SEPC        12'h141
`define CSR_SCAUSE      12'h142
`define CSR_STVAL       12'h143
`define CSR_SIP         12'h144
`define CSR_SATP        12'h180
`define CSR_SNECYCLE    12'h5C0


// synchronous (interrupt = 0) values are defined here.

/* Instruction address misaligned. */
`define I_ADDR_MISALIGNED   32'h0
/* Instruction access fault. */
`define I_ACCESS_FAULT      32'h1
/* Illegal instruction. */
`define I_ILLEGAL           32'h2
/* Breakpoint. */
`define BREAKPOINT          32'h3
/* Load address misaligned. */
`define L_ADDR_MISALIGNED   32'h4
/* Load access fault. */
`define L_ACCESS_FAULT      32'h5
/* Store/AMO address misaligned. */
`define S_ADDR_MISALIGNED   32'h6
/* Store/AMO access fault. */
`define S_ACCESS_FAULT      32'h7
/* Environment call from U-mode. */
`define U_CALL              32'h8
/* Environment call from S-mode. */
`define S_CALL              32'h9
/* Environment call from M-mode. */
`define M_CALL              32'hb

// asynchronous (interrupt = 1) values are defined here.

/* User software interrupt. */
`define U_INT_SW            32'h0
/* Supervisor software interrupt. */
`define S_INT_SW            32'h1
/* Machine software interrupt. */
`define M_INT_SW            32'h3
/* User timer interrupt. */
`define U_INT_TIMER         32'h4
/* Supervisor timer interrupt. */
`define S_INT_TIMER         32'h5
/* Machine timer interrupt. */
`define M_INT_TIMER         32'h7
/* User external interrupt. */
`define U_INT_EXT           32'h8
/* Supervisor external interrupt. */
`define S_INT_EXT           32'h9
/* Machine external interrupt. */
`define M_INT_EXT           32'hb

/* User. */
`define U 2'b00
/* Supervisor. */
`define S 2'b01
/* Reserved. */
`define R 2'b10
/* Machine. */
`define M 2'b11

module csr_regfile(
	input logic clk, nrst,
	input logic csr_we,
	input logic [11:0] csr_address_r, csr_address_wb,
	input logic [31:0] csr_wb,		// csr data written back from csr to the register file
	//inputs from execute stage
	input logic exception_pending,
	//input logic instruction_word,


	input logic [31:0] cause,
	input logic [31:0] pc_exc,		// pc of instruction that caused the exception >> (mepc - sepc - uepc)

 	input logic m_ret, s_ret, u_ret,	//MRET or SRET instruction is used to return from a trap in M-mode or S-mode respectively
	// input logic stall,
	input logic m_interrupt,
        input logic s_interrupt,
	input logic u_interrupt,

	output logic m_timer,
	output logic s_timer,
	output logic u_timer,
	output logic [31:0] csr_data,		// output to csr unit to perform operations on it
	output logic m_eie, m_tie,s_eie, s_tie,

	output logic u_eie, u_tie, u_sie,
	output logic [1:0] current_mode,
	
	// output to decode stage to decide sret or illegal instruction
	output logic TSR,

	// To front end
	output logic [31:0] epc
	);


	// registers
        logic [1:0] next_mode;

	// mstatus
	logic status_sie;
	logic status_mie;
	logic status_spie;
	logic status_mpie;
	logic status_spp;
	logic [1:0] status_mpp;
	logic status_TSR;
	logic status_sum;

	// ustatus
	logic status_upie;
  logic status_uie;

	// mie
	logic meie;
	logic seie;
	logic mtie;
	logic stie;

	// uip
	logic usip;
	logic utip;
	logic ueip;
	// uie
	logic usie;
	logic utie;
	logic ueie;

	// mcause
	logic mcause_interrupt;
	logic [`XLEN-2:0]mcause_code;
	//SCAUSE
	logic scause_interrupt;
	logic [`XLEN-2:0]scause_code;
	// ucause
	logic ucause_interrupt;
	logic [`XLEN-2:0]ucause_code;


	logic [`XLEN-1:2] mtvec;
        logic [`XLEN-1:2] stvec;
	logic [`XLEN-1:2] utvec;
	logic [`XLEN-1:0] mscratch;
        logic [`XLEN-1:0] sscratch;
	logic [`XLEN-1:0] uscratch;
	logic [`XLEN-1:0] mcause;
        logic [`XLEN-1:0] scause;
	logic [`XLEN-1:0] ucause;
	logic [`XLEN-1:0] mepc;
        logic [`XLEN-1:0] sepc;
	logic [`XLEN-1:0] uepc;

	logic [`XLEN-1:0] mtval;
	logic [`XLEN-1:0] utval;

	logic [15:0] medeleg;
	logic [11:0] mideleg;

	logic [15:0] sedeleg;
	logic [11:0] sideleg;


	logic [`XLEN-1:0] stval;

	// wires
	logic [`XLEN-1:0] mstatus;
	logic [`XLEN-1:0] mip;
	logic [`XLEN-1:0] mie;
        logic [`XLEN-1:0] sstatus;
	logic [`XLEN-1:0] sip;
	logic [`XLEN-1:0] sie;

	logic [`XLEN-1:0] ustatus;
	logic [`XLEN-1:0] uip;
	logic [`XLEN-1:0] uie;

	logic [`XLEN-1:0] medeleg_w;
	logic [`XLEN-1:0] mideleg_w;

	logic [`XLEN-1:0] sedeleg_w;
	logic [`XLEN-1:0] sideleg_w;


	//logic s_timer;
	logic [`XLEN-1:0] tvec_out ;



	logic[63:0] stimecmp;
        logic[63:0] utimecmp;
	logic [63:0]mtimecmp;
	logic [63:0] timer; 



	always_comb
	begin
		case(csr_address_r)
		// System ID Registers
		`CSR_MISA: csr_data = {
        		2'b01,       // MXL = 1 for XLEN = 32
       			4'b0000,     // Reserved.
        		/* Extensions.
        		 *  ZYXWVUTSRQPONMLKJIHGFEDCBA */
        		26'b00000101000011000100000000
    			};
		`CSR_MVENDORID:		csr_data = '0;
		`CSR_MARCHID:		csr_data = '0;
		`CSR_MIMPID:		csr_data = '0;
		`CSR_MHARTID:		csr_data = '0;

		`CSR_MSTATUS:		csr_data = mstatus;		// mstatus = sstatus
		`CSR_MIP:		csr_data = mip;
		`CSR_MIE:		csr_data = mie;			// Global interrupt-enable (Machine mode) -- interrupts disabled upon entry
		`CSR_MTVEC:		csr_data = {mtvec, 2'b0}; 	// direct mode
		`CSR_MEPC:		csr_data = {mepc[`XLEN-1:2], 2'b0};  	// two low bits are always zero
		`CSR_MCAUSE:		csr_data = mcause;
		`CSR_MTVAL:		csr_data = mtval;
		`CSR_MSCRATCH:		csr_data = mscratch;
                `CSR_MNECYCLE:          csr_data = mtimecmp;

		`CSR_MEDELEG: 		csr_data = medeleg_w;
   	        `CSR_MIDELEG: 		csr_data = mideleg_w;
		`CSR_TIMEH,`CSR_CYCLEH: csr_data = timer[63:32];
		`CSR_TIME,  `CSR_CYCLE: csr_data = timer[31:0];


               // S Mode
                `CSR_SEPC:	        csr_data = {sepc[`XLEN-1:2], 2'b0};
 		`CSR_SSTATUS:           csr_data = sstatus;
   		`CSR_SIE:               csr_data = sie;
   		`CSR_STVEC:             csr_data = {stvec, 2'b0};

   		`CSR_SSCRATCH:          csr_data = sscratch;
   		`CSR_SIP:               csr_data = sip;
   		`CSR_SCAUSE:            csr_data = scause;
 	 	`CSR_STVAL:             csr_data = stval;
  		`CSR_SNECYCLE:          csr_data = stimecmp;

  		 `CSR_SEDELEG: 	        csr_data = sedeleg_w;
  		 `CSR_SIDELEG: 	        csr_data = sideleg_w;

                //CSR_SCOUNTREN:


		// 	USER MODE
		`CSR_USTATUS:           csr_data = ustatus;
		`CSR_UIE:               csr_data = uie;
		`CSR_UIP:               csr_data = uip;
		`CSR_UTVEC:		csr_data = {utvec, 2'b0}; 	// direct mode
		`CSR_UEPC:		csr_data = {uepc[`XLEN-1:2], 2'b0};  	// two low bits are always zero
		`CSR_UCAUSE:		csr_data = ucause;
		`CSR_UTVAL:		csr_data = utval;
		`CSR_USCRATCH:		csr_data = uscratch;
    `CSR_UNECYCLE:          csr_data = utimecmp;
    default: csr_data = 0;


		endcase
	end


	assign mstatus = {
    9'b0,
    status_TSR,
    3'b0,
    status_sum,
    1'b0,
    4'b0,
    status_mpp,			// xPP holds the previous privilege mode
    2'b0,
    status_spp,			// xPP holds the previous privilege mode
    status_mpie,		// xPIE holds the value of the interrupt-enable bit active prior to the trap
    1'b0,
    status_spie,		// xPIE holds the value of the interrupt-enable bit active prior to the trap
    status_upie,
    status_mie,			// Global interrupt-enable (Machine mode) -- interrupts disabled upon entry
    1'b0,
    status_sie,			// Global interrupt-enable (Supervisor mode) -- interrupts disabled upon entry
    status_uie
	};

	// For user mode we need to add to mstatus (MPRV ),

	assign mip = {
		20'b0,
	    	m_interrupt,
	    	1'b0,
	    	s_interrupt,
	    	1'b0,
	    	m_timer,
	    	1'b0,
	    	s_timer,
	    	5'b0
	};

	assign mie = {
    		20'b0,
    		meie,
    		1'b0,
    		seie,
    		1'b0,
    		mtie,
    		1'b0,
    		stie,
    		5'b0
	};

	assign mcause = {
    		mcause_interrupt,
    		mcause_code
	};

	assign medeleg_w = {
		16'b0,
		medeleg
	};

	assign mideleg_w = {
		20'b0,
		mideleg
	};

	assign sstatus = {
		13'b0,
  		status_sum,
  		9'b0,
    		status_spp,
    		status_upie,
    		status_spie,
    		3'b0,
    		status_sie,
    		status_uie
	};
	assign sip = {
		22'b0,
    		s_interrupt,
    		3'b0,
    		s_timer,
    		5'b0
	};
	assign sie = {
    		22'b0,
    		seie,
    		3'b0,
    		stie,
    		5'b0
	};
	assign scause = {
		scause_interrupt,
		scause_code
	};



	assign sedeleg_w = {
		16'b0,
		sedeleg
	};

	assign sideleg_w = {
		20'b0,
		sideleg
	};


           // USER MODE

	assign ustatus = {
    		27'b0,
   		status_upie,
    		3'b0,
    status_uie
	};
	assign uip = {
  	  24'b0,
    	u_interrupt,
    	3'b0,
    	u_timer,
   	 3'b0,
   	 usip
	};
	assign uie = {
   	 24'b0,
   	 ueie,
   	 3'b0,
  	  utie,
  	  3'b0,
  	  usie
	};
	assign ucause = {
 	  ucause_interrupt,
   	 ucause_code
		};

always_ff @(posedge clk, negedge nrst) begin
	if (!nrst)
	  begin
		current_mode 		<=`M; // M-mode is the first mode entered at reset.
		status_sie  		<= 0;
    		status_mie  		<= 0;
    		status_spie 		<= 0;
 	 	status_mpie 		<= 0;
   		status_spp  		<= 0;
    		status_mpp  	        <=`M;
    		status_sum  		<= 0;
		mtvec	    		<= 0;
		mscratch		<= 0;
		mepc			<= 0;
		mtval			<= 0;
		meie			<= 0;
		seie 			<= 0;
		mtie 			<= 0;
		stie 			<= 0;

		mcause_interrupt 	<= 0;
    		mcause_code      	<= 0;

		scause_interrupt 	<= 0;
    		scause_code      	<= 0;

		ucause_interrupt 	<= 0;
    		ucause_code      	<= 0;

		medeleg			<= 0;
		mideleg			<= 0;

		sedeleg			<= 0;
		sideleg			<= 0;

		sscratch		<= 0;
        	stvec  	        	<= 0;
		sepc			<= 0;

		status_upie		<= 0;
		status_uie		<= 0;
		usip			<= 0;
		utip			<= 0;
		ueip			<= 0;
		usie			<= 0;
        	utie			<= 0;
		ueie			<= 0;
		utvec	    		<= 0;
		uscratch		<= 0;
		uepc			<= 0;
		utval			<= 0;
        	mtimecmp                <= 0;
        	stimecmp                <= 0;
       		utimecmp                <= 0;
end
	else
	  begin
	current_mode <= next_mode;
        if (!exception_pending) begin
     	  if(csr_we)begin
		case(csr_address_wb)
			`CSR_MSTATUS:
			  begin
			   status_sie  <= csr_wb[1];
			   status_mie  <= csr_wb[3];
			   status_spie <= csr_wb[5];
			   status_mpie <= csr_wb[7];
			   status_spp  <= csr_wb[8];
			   status_mpp  <= csr_wb[12:11];
			   status_sum  <= csr_wb[18];
			   status_TSR  <= csr_wb[22];           	
			  end
			  
			`CSR_MTVEC:
				mtvec <= csr_wb[`XLEN-1:2];
			`CSR_MIE:
			  begin
				stie <= csr_wb[5];
                        	mtie <= csr_wb[7];
                        	seie <= csr_wb[9];
                        	meie <= csr_wb[11];
			  end
			`CSR_MSCRATCH:
				mscratch <= csr_wb;
                        `CSR_MNECYCLE:
                                mtimecmp <= csr_wb;
			`CSR_MEPC:
				mepc <= {csr_wb[`XLEN-1:2], 2'b0};
			`CSR_MCAUSE:
			  begin
				mcause_code      <= csr_wb[5:0];
				mcause_interrupt <= csr_wb[31];
			  end
			`CSR_MTVAL:
				mtval <= csr_wb;
			`CSR_MEDELEG:
				medeleg <= csr_wb[15:0];
			`CSR_MIDELEG:
				mideleg <= csr_wb[11:0];

			// S Mode
			`CSR_SSTATUS:
			  begin
  				  status_sum <= csr_wb[18];
    				status_spp <= csr_wb[8];
    				status_spie <= csr_wb[5];
    				status_sie <= csr_wb[1];
			  end
                        `CSR_STVEC:
				stvec <= csr_wb[`XLEN-1:2];
			`CSR_SEPC:
                    		sepc <= {csr_wb[`XLEN-1:2], 2'b0};
			`CSR_SCAUSE:
              		  begin
               			scause_code <= csr_wb[5:0];
                		scause_interrupt <= csr_wb[31];
                          end
                        `CSR_STVAL:
				stval <= csr_wb;
                        `CSR_SIE:
			  begin
				stie <= csr_wb[5];
                                seie <= csr_wb[9];
                           end
                        `CSR_SSCRATCH:
				sscratch <= csr_wb;
			`CSR_SEDELEG:
				sedeleg <= csr_wb[15:0];
			`CSR_SIDELEG:
				sideleg <= csr_wb[11:0];
                        `CSR_SNECYCLE:
                                stimecmp <= csr_wb;
 

			// USER MODE
			`CSR_USTATUS:
				begin
					status_upie		<= csr_wb[4];
					status_uie		<= csr_wb[0];
				end
			`CSR_UIE:
				begin
					usie			<= csr_wb[0];
					utie			<= csr_wb[4];
					ueie			<= csr_wb[8];
					//stie			<= csr_wb[4];
					//seie			<= csr_wb[8];
					//mtie			<= csr_wb[4];
					//meie			<= csr_wb[8];

				end
			`CSR_UIP:
				begin
					usip			<= csr_wb[0];
					//ssip			<= csr_wb[0];
					//msip			<= csr_wb[0];
				end
			`CSR_USCRATCH:
				uscratch <= csr_wb;
			`CSR_UEPC:
				uepc <= {csr_wb[`XLEN-1:2], 2'b0};
			`CSR_UCAUSE:
			  begin
				mcause_code      <= csr_wb[5:0];
				mcause_interrupt <= csr_wb[31];
			  end
			`CSR_UTVAL:
				utval <= csr_wb;
			`CSR_UTVEC:
				utvec <= csr_wb[`XLEN-1:2];
                        `CSR_UNECYCLE:
                                utimecmp <= csr_wb;


		endcase
		end
	  end

	 //Exception logic
	else if (exception_pending && next_mode==`M && !m_ret)
	  begin
		  mepc <= {pc_exc[`XLEN-1:2],2'b0};
     	status_mie  <= 0;
     	status_mpie <= status_mie;
      status_mpp  <= current_mode;
      
      mcause_interrupt <= cause[`XLEN-1];
      mcause_code      <= cause[`XLEN-2:0];


		if (!cause[`XLEN-1])
		  begin
			case (cause[`XLEN-2:0])
                		`I_ADDR_MISALIGNED:   mtval <= {pc_exc[`XLEN-1:1], 1'b0};
                		`I_ILLEGAL:           mtval <= 0;			//{instruction_word, 2'b11};
                		default:              mtval <= 0;
			endcase
		  end

		else
		  begin
            mtval <= 0;
          end
	  end

    // return from interrupt
        else if (m_ret)
	  begin
            status_mie  <= status_mpie;
            status_mpie <= 1;
            status_mpp  <= `U;
	  end

        else if (exception_pending && next_mode==`S && !s_ret)
		begin
            sepc <= {pc_exc[`XLEN-1:2],2'b0};
            status_sie  <= 0;
            status_spie <= status_sie;
            status_spp  <= current_mode[0];
            scause_interrupt <= cause[`XLEN-1];  //interrupt_exception
            scause_code      <= cause[`XLEN-2:0];//exception_code


            if (!cause[`XLEN-1])
		begin
		case (cause[`XLEN-2:0])
                	`I_ADDR_MISALIGNED:   stval <= {pc_exc[`XLEN-1:1], 1'b0};
                	`I_ILLEGAL:           stval <= 0;			//{ instruction_word, 2'b11};
                	//exception::L_ADDR_MISALIGNED,
                	//exception::S_ADDR_MISALIGNED,
                	default:                        stval <= 0;
            	endcase
         	end
            else
			begin
                stval <= 0;
            end
		end

        else if (s_ret)
		begin
            status_sie  <= status_spie;
            status_spie <= 1;
            status_spp  <= 0;
		end
    //end

	// USER MODE
	else if (exception_pending && next_mode==`U && !u_ret)
	  begin
		uepc <= {pc_exc[`XLEN-1:2],2'b0};
        	status_uie  <= 0;
        	status_upie <= status_uie;

        	ucause_interrupt <= cause[`XLEN-1];
        	ucause_code      <= cause[`XLEN-2:0];


		if (!cause[`XLEN-1])
		  begin
			case (cause[`XLEN-2:0])
            `I_ADDR_MISALIGNED:   utval <= {pc_exc, 1'b0};
            `I_ILLEGAL:           utval <= 0;			//{instruction_word, 2'b11};
            default:              utval <= 0;
			endcase
		  end

		else
		  begin
            utval <= 0;
          	end
	  end

    // return from interrupt
        else if (u_ret)
	  begin
            status_uie  <= status_upie;
            status_upie <= 1;
	  end
    end
 end

// Figure out what mode we are switching to
always_comb
  begin
    next_mode = current_mode;
    if (exception_pending)
      begin
      // An xRET instruction can be executed in privilege mode x or higher, where executing a lower-privilege xRET
	    // instruction will pop the relevant lower-privilege interrupt enable and privilege mode stack
	    
        if (m_ret)
            next_mode = status_mpp;

	      else if (s_ret)
              next_mode = status_spp ? `S : `U;

        else if (u_ret)
        	     next_mode = `U;
        
        else if (cause[`XLEN-1])
          begin
            if (mideleg[cause[`XLEN-2:0]] && sideleg[cause[`XLEN-2:0]])
              next_mode = `U;
            else if (mideleg[cause[`XLEN-2:0]])
              next_mode = `S;
            else
              next_mode = `M; 
          end
        else if (!cause[`XLEN-1])
          begin
            if (medeleg[cause[`XLEN-2:0]] && sedeleg[cause[`XLEN-2:0]])
              next_mode = `U;
            else if (medeleg[cause[`XLEN-2:0]])
              next_mode = `S;
            else
              next_mode = `M;
          end
        
	     else
	       begin
	       next_mode = current_mode;
         end
    end
  end


  /* Counter for time and cycle CSRs. */ 
always @(posedge clk,negedge nrst) begin
	if (!nrst) 
             begin          
     	timer <= 0;
 	 end
	  else
              begin
   	 timer <= timer + 1;
	end
	end


/* machine's timer. */

always @(posedge clk ,negedge nrst) begin
	if (!nrst)  begin
	m_timer	<= 0;
	end
	else begin
    	m_timer <= (timer >= mtimecmp);
	end
end

/* Supervisor's timer. */

always @(posedge clk,negedge nrst) begin
	if (!nrst) begin
	s_timer <= 0;
	end
	else begin
        s_timer <= (timer >= stimecmp);
	end
end
/* User's timer. */

always @(posedge clk,negedge nrst) begin
	if (!nrst) begin
	u_timer <= 0;
	end
	else begin
        u_timer <= (timer >= utimecmp);
	end
end

// interrupts enable signals
assign m_eie = meie && status_mie;
assign m_tie = mtie && status_mie;
assign s_eie = seie && status_sie;
assign s_tie = stie && status_sie;
assign u_tie = utie && status_uie;
assign u_eie = ueie && status_uie;
assign u_sie = usie && status_uie;




   always_comb
        begin
          if (next_mode == `M)
            begin
                tvec_out = {mtvec, 2'b0};
            end
         else if (next_mode == `S)
            begin
                tvec_out = {stvec, 2'b0};
            end
          else 
            begin
                tvec_out = {utvec, 2'b0};
            end
           end
	// epc output to pc in frontend
	always_comb
	  begin
 		unique case({m_ret, s_ret, u_ret})
			3'b000: epc = tvec_out;
			3'b100:	epc = mepc;
			3'b010:	epc = sepc;
			3'b001:	epc = uepc;
			default: epc = tvec_out;
		endcase
	  end
	  
	  
  // output
  assign TSR = status_TSR;
  
endmodule