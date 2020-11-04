`include "define.sv"

module csr_regfile(
	input logic clk, nrst,
	input logic [11:0] csr_address_r, csr_address_wb,
	input logic [31:0] csr_wb,		// csr data written back from csr to the register file
	//inputs from execute stage
	input logic exception_pending,
	input logic [31:0] m_cause,
	input logic [31:0] pc_exc,		// pc of instruction that caused the exception >> mepc
 	input logic  m_ret, s_ret, u_ret,
	input logic stall,
	input logic m_interrupt,
	
	input logic asy_int,		//Asynchronus interrupt 

	output logic m_timer,
	output logic [31:0] csr_data,		// output to csr unit to perform operations on it
	output logic m_eie, m_tie,
	output mode::mode_t     current_mode = mode::M,
	
	// To front end
	output logic [31:0] mtvec_out,
	output logic pcsel_interrupt
);

mode::mode_t  next_mode;

// registers
// mstatus
logic status_sie;
logic status_mie;
logic status_spie;
logic status_mpie;
logic status_spp;
//mode::mode_t    status_mpp  = mode::U;
logic status_sum;
// mie
logic meie;
logic seie;
logic mtie;
logic stie;



logic [`XLEN-1:2] mtvec;
logic [`XLEN-1:0] mscratch;
logic [`XLEN-1:0] mcause;
logic [`XLEN-1:0] mepc;
logic [`XLEN-1:0] mtval;

// wires
logic [`XLEN-1:0] mstatus;
logic [`XLEN-1:0] mip;
logic [`XLEN-1:0] mie;

logic m_eie;
logic m_tie;

logic s_timer;

assign s_timer = 0; // hardwired to zero untill implementing s-mode

assign mtvec_out = {mtvec, 2'b0};
assign pcsel_interrupt = exception_pending && asy_int;


always_comb
  begin
	case(csr_address_r)
		`CSR_MISA: csr_data = {
        		2'b00,       // MXL = 32
       			4'b0000,     // Reserved.
        		/* Extensions.
        		 *  ZYXWVUTSRQPONMLKJIHGFEDCBA */
        		26'b00000000000001000100000001
    			};
		`CSR_MVENDORID:		csr_data = '0;
		`CSR_MARCHID:		csr_data = '0;
		`CSR_MIMPID:		csr_data = '0;
		`CSR_MHARTID:		csr_data = '0;
		`CSR_MSTATUS:		csr_data = mstatus;
		`CSR_MIP:		csr_data = mip;
		`CSR_MIE:		csr_data = mie;
		`CSR_MTVEC:		csr_data = {mtvec, 2'b0}; // direct mode
		`CSR_MEPC:		csr_data = {mepc, 2'b0};  // two low bits are always zero
		`CSR_MCAUSE:		csr_data = mcause;
		`CSR_MTVAL:		csr_data = mtval;
		`CSR_MSCRATCH:		csr_data = mscratch;

/** not implemented yet **
		`CSR_MEDELEG:	// will be implemented in s-mode
		`CSR_MIDELEG:	// will be implemented in s-mode
		`CSR_MCOUNTEREN:
		`CSR_MCYCLE:
		`CSR_MINSTRET:
		`CSR_MCYCLEH:
		`CSR_MINSTRETH:
		`CSR_CYCLEH:
		`CSR_TIMEH:
		`CSR_INSTRETH:
**			    */

	endcase
  end

assign mstatus = {
    14'b0,
    status_sum,
    1'b0,
    4'b0,
    status_mpp,
    2'b0,
    status_spp,
    status_mpie,
    1'b0,
    status_spie,
    1'b0,
    status_mie,
    1'b0,
    status_sie,
    1'b0
};

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
/////////////////////////////////////////////////////////////////////////
always_comb begin
if (mret) begin
            mstatus_return.mie = mstatus.mpie;
            mstatus_return.mpie = 1;
            mstatus_return.mpp = ENABLE_U_MODE ? USER_PRIVILEGE : MACHINE_PRIVILEGE;
end
/////////////////////////////////////////////////////////////////////////////

always_ff @(posedge clk, negedge nrst) begin
	if (!nrst)
	  begin
		status_sie  	<= 0;
                status_mie  	<= 0;
                status_spie 	<= 0;
 		status_mpie 	<= 0;
                status_spp  	<= 0;
                status_mpp  	<= 0;
                status_sum  	<= 0;
		mtvec	    	<= '0;
		mscratch	<= '0;
		mepc		<= '0;
		mtval		<= '0;
		meie		<= 0;
		seie 		<= 0;
		mtie 		<= 0;
		stie 		<= 0;
	  end
	else
	  begin
	    /////////////////////////////////////////
	     current_mode <= next_mode;
        if (!exception_pending) begin
          /////////////////////////////////////////////////////////////////
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
			  end
			`CSR_MTVEC:
				mtvec <= csr_wb[`XLEN:2];
			`CSR_MEDELEG:
				begin end
			`CSR_MIDELEG:
				begin end
			`CSR_MIE:
			  begin
				stie <= csr_wb[5];
                        	mtie <= csr_wb[7];
                        	seie <= csr_wb[9];
                        	meie <= csr_wb[11];
			  end
			`CSR_MSCRATCH: 
				mscratch <= csr_wb;
			`CSR_MEPC:
				mepc <= csr_wb[31:2];
			`CSR_MCAUSE:
			  begin
				mcause_code <= csr_wb[5:0];
				mcause_interrupt <= csr_wb[31];
			  end
			`CSR_MTVAL:
				mtval <= csr_wb;
		endcase
	  end
	 //Exception logic
	  else if (next_mode==mode::M && !m_ret) begin
           // mepc <= instruction_vaddr[`XLEN-1:2];
            status_mie  <= 0;
            status_mpie <= status_mie;
            status_mpp  <= current_mode;
          //  mcause_interrupt <= interrupt_exception;
           // mcause_code      <= exception_code;
          end
    // return from interrupt 
        else if (m_ret) begin
            status_mie  <= status_mpie;
            status_mpie <= 1;
            status_mpp  <= mode::U;
      end
	 
	end

// Figure out what mode we are switching to
always_comb begin
    next_mode = current_mode;
    if (exception_pending) begin
        if (m_ret) begin
            next_mode = status_mpp;
        end

	 
// interrupts enable signals
assign m_eie = meie && status_mie;
assign m_tie = mtie && status_mie;

endmodule
