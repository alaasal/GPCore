interface exe_if(
    bit clk; nrst;
	bit [31:0] op_a;
 	bit [31:0] op_b;
	bit [4:0] rd4;			// rd address from issue stage
	bit [4:0] rs1_4; // rs1 from issue to execute to csr_unit
	bit [2:0] fn4;
	bit [3:0] alu_fn4;
	bit we4;
	bit [31:0] B_imm4;
	bit [31:0] J_imm4;
	bit [31:0] U_imm4 ;
	bit [31:0] S_imm4;
	bit bneq4;
	bit btype4;
	bit j4;
	bit jr4;
	bit LUI4;
	bit auipc4;
	bit [3:0] mem_op4;
	bit [3:0] mulDiv_op4;
	bit [31:0] pc4;
	bit [1:0] pcselect4;
	bit stall_mem;dmem_finished;
	// csr
	bit [2:0] funct3_4;
	bit [31:0] csr_data; csr_imm4;
	bit [11:0] csr_addr4;
	bit csr_we4;

	// exceptions
	bit instruction_addr_misaligned4;
	bit ecall4; ebreak4;
	bit illegal_instr4;
	bit mret4, sret4, uret4;
	bit m_timer, s_timer, u_timer;
 	bit [1:0] current_mode,
	bit m_tie, s_tie, m_eie, s_eie, u_eie, u_tie,u_sie;
	bit external_interrupt;


	bit [31:0] wb_data6;
	bit we6;
	bit [4:0] rd6;
	bit [31:0] U_imm6;
	bit [31:0] AU_imm6 ;
	bit [31:0] mul_divReg6;
	bit [31:0] target;
	bit [31:0] pc6;
	bit [1:0] pcselect5;
    //OpenPiton Request
	bit [3:0] mem_l15_rqtype;
	bit [2:0] mem_l15_size;
	bit [31:0] mem_l15_address;
	bit [63:0] mem_l15_data;
    bit mem_l15_val;
	//OpenPiton Response
	bit [63:0] l15_mem_data_0;
    bit [63:0] l15_mem_data_1;
	bit [3:0] l15_mem_returntype;
    bit l15_mem_val;
    bit l15_mem_ack;
	bit l15_mem_header_ack;
    bit mem_l15_req_ack;
    bit memOp_done;
    bit ld_addr_misaligned6;
    bit samo_addr_misaligned6;
	bit bjtaken6;		//need some debug
	bit exception;
	bit [31:0] csr_wb;
	bit [11:0] csr_wb_addr;
	bit csr_we6;
	// exceptions
	//bit pc_exc;
	bit [31:0] cause6;
	bit exception_pending;
	bit mret6, sret6, uret6;
	bit m_interrupt, s_interrupt, u_interrupt;

    initial begin 
        #10 rst = 1;
        forever #10 clk = ~clk;
    end



    );
