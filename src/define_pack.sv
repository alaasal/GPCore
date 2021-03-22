// CSR Addr  
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

package exceptions;

// synchronous (interrupt = 0) values are defined here.

typedef enum logic[30:0] {
    	/* Instruction address misaligned. */
    	I_ADDR_MISALIGNED = 0,
    	/* Instruction access fault. */
    	I_ACCESS_FAULT = 1,
    	/* Illegal instruction. */
    	I_ILLEGAL = 2,
    	/* Breakpoint. */
    	BREAKPOINT = 3,
    	/* Load address misaligned. */
    	L_ADDR_MISALIGNED = 4,
    	/* Load access fault. */
    	L_ACCESS_FAULT = 5,
    	/* Store/AMO address misaligned. */
    	S_ADDR_MISALIGNED = 6,
    	/* Store/AMO access fault. */
    	S_ACCESS_FAULT = 7,
    	/* Environment call from U-mode. */
    	U_CALL = 8,
    	/* Environment call from S-mode. */
    	S_CALL = 9,
    	/* Environment call from M-mode. */
    	M_CALL = 11
	}sync_codes_t;

 // asynchronous (interrupt = 1) values are defined here.

typedef enum logic[30:0] {
    	/* User software interrupt. */
    	U_INT_SW = 0,
    	/* Supervisor software interrupt. */
    	S_INT_SW = 1,
    	/* Machine software interrupt. */
    	M_INT_SW = 3,
    	/* User timer interrupt. */
    	U_INT_TIMER = 4,
    	/* Supervisor timer interrupt. */
    	S_INT_TIMER = 5,
    	/* Machine timer interrupt. */
    	M_INT_TIMER = 7,
    	/* User external interrupt. */
    	U_INT_EXT = 8,
    	/* Supervisor external interrupt. */
    	S_INT_EXT = 9,
    	/* Machine external interrupt. */
    	M_INT_EXT = 11
	}async_codes_t;

endpackage
