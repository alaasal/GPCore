`define XLEN 32

package mode;

/* RISC-V execution mode. */
typedef enum logic [1:0] {
    	/* User. */
    	U,
    	/* Supervisor. */
    	S,
    	/* Reserved. */
    	R,
    	/* Machine. */
    	M
	}mode_t;

endpackage


package csr;

//
typedef enum logic [31:0]{
	//XLEN = 32,

/**************************************************************************************************/
/**** exception & interrupt                                                                    ****/
/**************************************************************************************************/
	CAUSE_INTERRUPT = 32'h80000000, // msb of mcause register = 1 then interrupt not exception

// if not msb = 1 then exception
// EXEPTION CODE				// exception code according to the manual this will define the trap handler
 	CAUSE_MISALIGNED_FETCH =     32'h0,
 	CAUSE_FAULT_FETCH     =      32'h1,
 	CAUSE_ILLEGAL_INSTRUCTION =  32'h2,
 	CAUSE_BREAKPOINT        =    32'h3,
 	CAUSE_MISALIGNED_LOAD     =  32'h4,
 	CAUSE_FAULT_LOAD         =   32'h5,
 	CAUSE_MISALIGNED_STORE   =   32'h6,
 	CAUSE_FAULT_STORE        =   32'h7,
 	CAUSE_USER_ECALL         =   32'h8,
 	CAUSE_SUPERVISOR_ECALL   =   32'h9,
 	CAUSE_HYPERVISOR_ECALL   =   32'ha,
 	CAUSE_MACHINE_ECALL      =   32'hb,
 	CAUSE_FETCH_PAGE_FAULT   =   32'hc,
 	CAUSE_LOAD_PAGE_FAULT    =   32'hd,
 	CAUSE_STORE_PAGE_FAULT  =    32'hf
	}cause_code;

typedef enum logic [11:0]{
// Machine-Mode
 	CSR_MVENDORID  = 12'hf11,	//Machine Vendor ID Register (mvendorid) [p18]
 	CSR_MARCHID    = 12'hf12,	//Machine Architecture ID Register (marchid)  [p18]
 	CSR_MIMPID     = 12'hf13,	//Machine Implementation ID Register (mimpid) p[19]
 	CSR_MHARTID    = 12'hf14,	//Hart ID Register (mhartid) p[19]
 	CSR_MSTATUS    = 12'h300,	//Machine Status Registers (mstatus and mstatush) p[20]
 	CSR_MISA       = 12'h301,	//Machine ISA Register (misa) [p15]
 	CSR_MEDELEG    = 12'h302,	//Machine Trap Delegation Registers (medeleg and mideleg p[29]
 	CSR_MIDELEG    = 12'h303,	//Machine Trap Delegation Registers (medeleg and mideleg p[29]
 	CSR_MIE        = 12'h304,	//Machine Interrupt Registers (mip and mie) p[31]
 	CSR_MTVEC      = 12'h305,	//Machine Trap-Vector Base-Address Register (mtvec) p[28]
 	CSR_MCOUNTEREN = 12'h306,
 	CSR_MSCRATCH   = 12'h340,
 	CSR_MEPC       = 12'h341,
 	CSR_MCAUSE     = 12'h342,
 	CSR_MTVAL      = 12'h343,
 	CSR_MIP        = 12'h344,	//Machine Interrupt Registers (mip and mie) p[31]
 	CSR_MCYCLE     = 12'hb00,	//**Hardware Performance Monitor p[35]
 	CSR_MINSTRET   = 12'hb02,	//**Hardware Performance Monitor p[35]
 	CSR_MCYCLEH    = 12'hb80,
 	CSR_MINSTRETH  = 12'hb82,
 	CSR_CYCLEH     = 12'hc80,
 	CSR_TIMEH      = 12'hc81,	//**Machine Timer Registers (mtime and mtimecmp) p[33]
 	CSR_INSTRETH   = 12'hc82,
 	CSR_MNECYCLE   = 12'hbbf,

	// User-Mode
	CSR_USTATUS    = 12'h000,
 	CSR_FFLAGS     = 12'h001,
 	CSR_FRM        = 12'h002,
 	CSR_FCSR       = 12'h003,
 	CSR_UIE        = 12'h004,
 	CSR_UTVEC      = 12'h005,
 	CSR_USCRATCH   = 12'h040,
 	CSR_UEPC       = 12'h041,
 	CSR_UCAUSE     = 12'h042,
 	CSR_UTVAL      = 12'h043,
 	CSR_UIP        = 12'h044,
 	CSR_CYCLE      = 12'hc00,
 	CSR_TIME       = 12'hc01,
 	CSR_INSTRET    = 12'hc02,
 	CSR_UNECYCLE   = 12'h8ff,

	// Superviser-Mode
	CSR_SSTATUS    = 12'h100,
 	CSR_SEDELEG    = 12'h102,
 	CSR_SIDELEG    = 12'h103,
 	CSR_SIE        = 12'h104,
 	CSR_STVEC      = 12'h105,
 	CSR_SCOUNTEREN = 12'h106,
 	CSR_SSCRATCH   = 12'h140,
 	CSR_SEPC       = 12'h141,
 	CSR_SCAUSE     = 12'h142,
 	CSR_STVAL      = 12'h143,
 	CSR_SIP        = 12'h144,
 	CSR_SATP       = 12'h180,
 	CSR_SNECYCLE   = 12'h5C0
	}csrs;

endpackage



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
	//output mode::mode_t     current_mode = mode::M,
	output mode::mode_t     current_mode,

	// To front end
	output logic [31:0] epc
	);
	import csr::*;

	mode::mode_t  next_mode;


	// registers
	// mstatus
	logic status_sie;
	logic status_mie;
	logic status_spie;
	logic status_mpie;
	logic status_spp;
	//mode::mode_t status_mpp  = mode::U;
	mode::mode_t status_mpp;
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
	logic [`XLEN-1:0] mtvec_out ;
	assign mtvec_out = {mtvec, 2'b0};


	logic[63:0] stimecmp;
        logic[63:0] utimecmp;
	logic [63:0]mtimecmp;
	logic [63:0] mtime;



	always_comb
	begin
		case(csr::csrs'(csr_address_r))
		// System ID Registers
		CSR_MISA: csr_data = {
        		2'b01,       // MXL = 1 for XLEN = 32
       			4'b0000,     // Reserved.
        		/* Extensions.
        		 *  ZYXWVUTSRQPONMLKJIHGFEDCBA */
        		26'b00000101000011000100000001
    			};
		CSR_MVENDORID:		csr_data = '0;
		CSR_MARCHID:		csr_data = '0;
		CSR_MIMPID:		csr_data = '0;
		CSR_MHARTID:		csr_data = '0;

		CSR_MSTATUS:		csr_data = mstatus;		// mstatus = sstatus
		CSR_MIP:		csr_data = mip;
		CSR_MIE:		csr_data = mie;			// Global interrupt-enable (Machine mode) -- interrupts disabled upon entry
		CSR_MTVEC:		csr_data = {mtvec, 2'b0}; 	// direct mode
		CSR_MEPC:		csr_data = {mepc, 2'b0};  	// two low bits are always zero
		CSR_MCAUSE:		csr_data = mcause;
		CSR_MTVAL:		csr_data = mtval;
		CSR_MSCRATCH:		csr_data = mscratch;
                CSR_MNECYCLE:           csr_data = mtimecmp;

		CSR_MEDELEG: 		csr_data = medeleg_w;
        	CSR_MIDELEG: 		csr_data = mideleg_w;
		CSR_TIMEH, CSR_CYCLEH:
				csr_data = mtime[63:32];
		CSR_TIME, CSR_CYCLE:
				csr_data = mtime[31:0];


              // S Mode
		CSR_SEPC:	       csr_data = {sepc, 2'b0};
                CSR_SSTATUS:           csr_data = sstatus;
                CSR_SIE:               csr_data = sie;
                CSR_STVEC:             csr_data = {stvec, 2'b0};

                CSR_SSCRATCH:          csr_data = sscratch;
                CSR_SIP:               csr_data = sip;
                CSR_SCAUSE:            csr_data = scause;
                CSR_STVAL:             csr_data = stval;
                CSR_SNECYCLE:          csr_data = stimecmp;

		CSR_SEDELEG: 		csr_data = sedeleg_w;
		CSR_SIDELEG: 		csr_data = sideleg_w;

			//CSR_SCOUNTREN:


		// 	USER MODE
		CSR_USTATUS:           csr_data = ustatus;
		CSR_UIE:               csr_data = uie;
		CSR_UIP:               csr_data = uip;
		CSR_UTVEC:		csr_data = {utvec, 2'b0}; 	// direct mode
		CSR_UEPC:		csr_data = {uepc, 2'b0};  	// two low bits are always zero
		CSR_UCAUSE:		csr_data = ucause;
		CSR_UTVAL:		csr_data = utval;
		CSR_USCRATCH:		csr_data = uscratch;
                CSR_UNECYCLE:           csr_data = utimecmp;



		endcase
	end


	assign mstatus = {
    13'b0,
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

	// For user mode we need to add to mstatus (MPRV ,

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
    mcause_interrupt,
    mcause_code
};

always_ff @(posedge clk, negedge nrst) begin
	if (!nrst)
	  begin
		current_mode 		<= mode::M; // M-mode is the first mode entered at reset.
		status_sie  		<= 0;
    		status_mie  		<= 0;
    		status_spie 		<= 0;
 	 	status_mpie 		<= 0;
   		status_spp  		<= 0;
    		status_mpp  		<= mode::M;
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
        	mtimecmp <=0;
        	stimecmp <=0;
       		utimecmp  <=0;
end
	else
	  begin
	current_mode <= next_mode;
        if (!exception_pending) begin
     	  if(csr_we)begin
		case(csr::csrs'(csr_address_wb))
			CSR_MSTATUS:
			  begin
				status_sie  <= csr_wb[1];
                        	status_mie  <= csr_wb[3];
                        	status_spie <= csr_wb[5];
                        	status_mpie <= csr_wb[7];
                        	status_spp  <= csr_wb[8];
                        	status_mpp  <= mode::mode_t'(csr_wb[12:11]);
                        	status_sum  <= csr_wb[18];
			  end
			CSR_MTVEC:
				mtvec <= csr_wb[`XLEN-1:2];
			CSR_MIE:
			  begin
				stie <= csr_wb[5];
                        	mtie <= csr_wb[7];
                        	seie <= csr_wb[9];
                        	meie <= csr_wb[11];
			  end
			CSR_MSCRATCH:
				mscratch <= csr_wb;
                        CSR_MNECYCLE:
                                       mtimecmp <= csr_wb;
			CSR_MEPC:
				mepc <= csr_wb[`XLEN-1:2];
			CSR_MCAUSE:
			  begin
				mcause_code      <= csr_wb[5:0];
				mcause_interrupt <= csr_wb[31];
			  end
			CSR_MTVAL:
				mtval <= csr_wb;
			CSR_MEDELEG:
				medeleg <= csr_wb[15:0];
			CSR_MIDELEG:
				mideleg <= csr_wb[11:0];

			// S Mode
			CSR_SSTATUS:
			  begin
  				status_sum <= csr_wb[18];
    				status_spp <= csr_wb[8];
    				status_spie <= csr_wb[5];
    				status_sie <= csr_wb[1];
			  end
                        CSR_STVEC:
				stvec <= csr_wb[`XLEN-1:2];
			CSR_SEPC:
                    		sepc <= csr_wb[`XLEN-1:2];
			CSR_SCAUSE:
              		  begin
               			scause_code <= csr_wb[5:0];
                		scause_interrupt <= csr_wb[31];
                          end
                        CSR_STVAL:
				stval <= csr_wb;
                        CSR_SIE:
			  begin
				stie <= csr_wb[5];
                             	seie <= csr_wb[9];
                           end
                        CSR_SSCRATCH:
				sscratch <= csr_wb;
			CSR_SEDELEG:
				sedeleg <= csr_wb[15:0];
			CSR_SIDELEG:
				sideleg <= csr_wb[11:0];
                        CSR_SNECYCLE:
                                       stimecmp <= csr_wb;


			// USER MODE
			CSR_USTATUS:
				begin
					status_upie		<= csr_wb[4];
					status_uie		<= csr_wb[0];
				end
			CSR_UIE:
				begin
					usie			<= csr_wb[0];
					utie			<= csr_wb[4];
					ueie			<= csr_wb[8];
					//stie			<= csr_wb[4];
					//seie			<= csr_wb[8];
					//mtie			<= csr_wb[4];
					//meie			<= csr_wb[8];

				end
			CSR_UIP:
				begin
					usip			<= csr_wb[0];
					//ssip			<= csr_wb[0];
					//msip			<= csr_wb[0];
				end
			CSR_USCRATCH:
				uscratch <= csr_wb;
			CSR_UEPC:
				uepc <= csr_wb[31:2];
			CSR_UCAUSE:
			  begin
				mcause_code      <= csr_wb[5:0];
				mcause_interrupt <= csr_wb[31];
			  end
			CSR_UTVAL:
				utval <= csr_wb;
			CSR_UTVEC:
				utvec <= csr_wb[`XLEN-1:2];
                        CSR_UNECYCLE:
                                       utimecmp <= csr_wb;


		endcase
		end
	  end

	 //Exception logic
	else if (exception_pending && next_mode==mode::M && !m_ret)
	  begin
		mepc <= {pc_exc[`XLEN-1:2],2'b00};
        	status_mie  <= 0;
        	status_mpie <= status_mie;
        	status_mpp  <= current_mode;

        	mcause_interrupt <= cause[`XLEN-1];
        	mcause_code      <= cause[`XLEN-2:0];


		if (!cause[`XLEN-1])
		  begin
			case (cause[`XLEN-2:0])
                		exceptions::I_ADDR_MISALIGNED:   mtval <= {pc_exc[31:1], 1'b0};
                		exceptions::I_ILLEGAL:           mtval <= 0;			//{instruction_word, 2'b11};
                		default:                        mtval <= 0;
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
            status_mpp  <= mode::U;
	  end

        else if (exception_pending && next_mode==mode::S && !s_ret)
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
                	exceptions::I_ADDR_MISALIGNED:   stval <= {pc_exc[31:1], 1'b0};
                	exceptions::I_ILLEGAL:           stval <= 0;			//{ instruction_word, 2'b11};
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
	else if (exception_pending && next_mode==mode::U && !u_ret)
	  begin
		uepc <= {pc_exc[`XLEN-1:2],2'b0};
        	status_uie  <= 0;
        	status_upie <= status_uie;

        	ucause_interrupt <= cause[`XLEN-1];
        	ucause_code      <= cause[`XLEN-2:0];


		if (!cause[`XLEN-1])
		  begin
			case (cause[`XLEN-2:0])
            exceptions::I_ADDR_MISALIGNED:   utval <= {pc_exc, 1'b0};
            exceptions::I_ILLEGAL:           utval <= 0;			//{instruction_word, 2'b11};
            default:                        utval <= 0;
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
always_comb begin
    next_mode = current_mode;
    if (exception_pending) begin
        if (m_ret) begin
            next_mode = status_mpp;
        end
	else if (s_ret) begin
            next_mode = status_spp ? mode::S : mode::U;
        end
        else if (u_ret)
	  begin
        	next_mode = mode::U;
        end
	else if (current_mode == mode::S)
	  begin
		if (cause[`XLEN-1])
            		next_mode = mideleg[cause[`XLEN-2:0]] ? mode::S : mode::M;
		else
			next_mode = medeleg[cause[`XLEN-2:0]] ? mode::S : mode::M;
	  end

        else if (current_mode == mode::U)
	  begin
		if (cause[`XLEN-1])
            		next_mode = sideleg[cause[`XLEN-2:0]] ? mode::U : mode::S;
		else
			next_mode = sedeleg[cause[`XLEN-2:0]] ? mode::U : mode::S;
	end
    end
end

/* Counter for time and cycle CSRs. */

always @(posedge clk,negedge nrst) begin
if (!nrst)  begin
     mtime <=0;
  end
  else begin
    mtime <= mtime + 1;
end
end


/* machine's timer. */

always @(posedge clk ,negedge nrst) begin
	if (!nrst)  begin
	m_timer	<= 0;
	end
	else begin
    	m_timer <= (mtime >= mtimecmp);
	end
end

/* Supervisor's timer. */

always @(posedge clk,negedge nrst) begin
	if (!nrst) begin
	s_timer <= 0;
	end
	else begin
        s_timer <= (mtime >= stimecmp);
	end
end
/* User's timer. */

always @(posedge clk,negedge nrst) begin
	if (!nrst) begin
	u_timer <= 0;
	end
	else begin
        u_timer <= (mtime >= utimecmp);
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

	// epc output to pc in frontend
	always_comb
	  begin
		unique case({m_ret, s_ret, u_ret})
			3'b000: epc = mtvec_out;
			3'b100:	epc = mepc;
			3'b010:	epc = sepc;
			3'b001:	epc = uepc;
			default: epc = mtvec_out;
		endcase
	  end
endmodule
