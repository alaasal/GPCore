`include "define.sv"

module csr_regfile(
	input logic clk, nrst,
	input logic [11:0] csr_address_r, csr_address_wb,
	input logic [31:0] csr_wb,		// csr data written back from csr to the register file
	//inputs from execute stage
	input logic exception_pending,

	//input logic [5:0] exception_code,
	//input logic interrupt_exception,
	
	input logic [31:0] m_cause,
	input logic [31:0] pc_exc,		// pc of instruction that caused the exception >> mepc
	input logic [31:2] instruction_word,  // type of exception
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
// mcause
logic mcause_interrupt;
logic [`XLEN-2:0]mcause_code;



logic [`XLEN-1:2] mtvec;
logic [`XLEN-1:0] mscratch;
logic [`XLEN-1:0] mcause;
logic [`XLEN-1:0] mepc;
logic [`XLEN-1:0] mtval;
logic [`XLEN-1:0] medeleg;
logic [`XLEN-1:0] mideleg;

// wires
logic [`XLEN-1:0] mstatus;
logic [`XLEN-1:0] mip;
logic [`XLEN-1:0] mie;

logic m_eie;
logic m_tie;

logic s_timer;

assign s_timer = 0; // hardwired to zero untill implementing s-mode

assign mtvec_out = {mtvec, 2'b0};

assign pcsel_interrupt = exception_pending || asy_int;



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
		`CSR_MIP:			csr_data = mip;
		`CSR_MIE:			csr_data = mie;
		`CSR_MTVEC:			csr_data = {mtvec, 2'b0}; // direct mode
		`CSR_MEPC:			csr_data = {mepc, 2'b0};  // two low bits are always zero
		`CSR_MCAUSE:		csr_data = mcause;
		`CSR_MTVAL:			csr_data = mtval;
		`CSR_MSCRATCH:		csr_data = mscratch;
		
		`CSR_MEDELEG: 		csr_data = medeleg;
        `CSR_MIDELEG: 		csr_data = mideleg;
		
		// S Mode
		`CSR_SEPC:      	csr_data = {sepc, 2'b0};

/** not implemented yet **
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

assign mcause = {
    mcause_interrupt,
    mcause_code
};


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

		mcause_interrupt <=0;
    mcause_code      <=0;

		
		medeleg		<= 0;
		mideleg		<= 0;
		
		sepc		<= 0;

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
			`CSR_SEPC:
                    sepc <= csr_wb[32:2];
			`CSR_SCAUSE:
              begin
                scause_code <= new_value[5:0];
                scause_interrupt <= new_value[31];
              end
			
		endcase
	  end
	 //Exception logic
	  else if (next_mode==mode::M && !m_ret) begin
            mepc <= pc_exc[`XLEN-1:2];
            status_mie  <= 0;
            status_mpie <= status_mie;
            status_mpp  <= current_mode;

            mcause_interrupt <= m_cause[`XLEN-1];
            mcause_code      <= m_cause[`XLEN-2:0];

          end
    // return from interrupt 
        else if (m_ret) begin
            status_mie  <= status_mpie;
            status_mpie <= 1;
            status_mpp  <= mode::U;
		end
		
		if (!m_cause[`XLEN-1]) 
				case (m_cause[`XLEN-2:0])
                exception::I_ADDR_MISALIGNED:   mtval <= {pc_exc, 1'b0};
                /* Despite the ISA spec allowing the instruction cache to be compressed by dropping the bottom 2 bits,
                 * this will expose this detail to code running on the target.
                 * This should not be an issue in practice though.
                 */
                exception::I_ILLEGAL:           mtval <= {32'b0, instruction_word, 2'b11};

                /* This is not entirely compliant to the spec, but our machine mode is special anyway. */
                default:                        mtval <= add_result;
            endcase
            else begin
                mtval <= 0;
            end
        end
        else if (m_ret) begin
            status_mie  <= status_mpie;
            status_mpie <= 1;
            status_mpp  <= mode::U;
        end
        else if (exception_pending && next_mode==mode::S && !s_ret) begin
            sepc <= pc_exc[`XLEN-1:2];
            status_sie  <= 0;
            status_spie <= status_sie;
            status_spp  <= current_mode[0];
            scause_interrupt <= m_cause[`XLEN-1];  //interrupt_exception
            scause_code      <= m_cause[`XLEN-2:0];//exception_code

            if (!m_cause[`XLEN-1]) case (m_cause[`XLEN-2:0])
                exception::I_ADDR_MISALIGNED:   stval <= {pc_exc, 1'b0};
                /* Despite the ISA spec allowing the instruction cache to be compressed by dropping the bottom 2 bits,
                 * this will expose this detail to code running on the target.
                 * This should not be an issue in practice though.
                 */
                exception::I_ILLEGAL:           stval <= {32'b0, instruction_word, 2'b11};
                exception::L_ADDR_MISALIGNED,
                exception::S_ADDR_MISALIGNED,

                default:                        stval <= 0;
            endcase
            else begin
                stval <= 0;
            end
        end
        else if (s_ret) begin
            status_sie  <= status_spie;
            status_spie <= 1;
            status_spp  <= 0;
        end
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
        else if (m_cause[`XLEN-1]) begin
            next_mode = mideleg[m_cause[`XLEN-2:0]] ? mode::S : mode::M;
        end
        else begin
            next_mode = medeleg[m_cause[`XLEN-2:0]] ? mode::S : mode::M;
        end
    end
end

	 
// interrupts enable signals
assign m_eie = meie && status_mie;
assign m_tie = mtie && status_mie;

endmodule
