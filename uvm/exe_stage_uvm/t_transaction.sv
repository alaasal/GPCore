import uvm_pkg::*;
include "uvm_macros.svh";

class t_transaction extends uvm_transaction;
  
  `uvm_object_utils(t_transaction)
  
  rand logic [31:0] op_a;
 	rand logic [31:0] op_b;
	rand logic [4:0] rd4;
			
	rand logic [4:0] rs1_4;

	rand logic [2:0] fn4;
	rand logic [3:0] alu_fn4;

	rand logic we4;

	rand logic [31:0] B_imm4;
	rand logic [31:0] J_imm4;
	rand logic [31:0] U_imm4 ;
	rand logic [31:0] S_imm4;

	rand logic bneq4;
	rand logic btype4;

	rand logic j4;
	rand logic jr4;
	rand logic LUI4;
	rand logic auipc4;

	rand logic [3:0] mem_op4;
	rand logic [3:0] mulDiv_op4; 

	rand logic [31:0] pc4;
	rand logic [1:0] pcselect4;
	rand logic stall_mem,dmem_finished;
	// csr
	rand logic [2:0] funct3_4;
	rand logic [31:0] csr_data, csr_imm4;
	rand logic [11:0] csr_addr4;
	rand logic csr_we4;

	// exceptions
	rand logic instruction_addr_misaligned4;
	rand logic ecall4, ebreak4;
	rand logic illegal_instr4;
	rand logic mret4, sret4, uret4;
	rand logic m_timer,s_timer, u_timer;
 	rand logic [1:0] current_mode;
	rand logic m_tie, s_tie, m_eie, s_eie,u_eie,u_tie,u_sie;
	rand logic external_interrupt;
	
	logic nrst;
  
  function new (string name = "t_transaction");
      super.new(name);
    endfunction
  
  constraint mem_alu_mul_div{ fn4 inside {3'b000,3'b001,3'b010,3'b011,3'b100};}
  
  constraint alu_function{ alu_fn4 inside {4'b0000,4'b0001,4'b0010,4'b0011,4'b0100,4'b0101,
                                           4'b0110,4'b0111,4'b1000,4'b1001,4'b1010,4'b1101};}
  
  constraint pc_select { if (j4 | jr4 | btype4){
                            pcselect4 == 2'b10;
                          } else{
                          pcselect4 == 2'b00;
                          }
                        }
                        
  constraint mem_operation { mem_op4 inside {4'b0000,4'b1111,4'b1011,4'b1101,4'b0111, 4'b0011,
                                       4'b0010,4'b0101,4'b0100};}
                                       
  constraint MulDiv_operation { mulDiv_op4 inside {4'b0000,4'b0011,4'b0101,4'b0111,4'b0110,4'b1001,   
                                                    4'b1011,4'b1101,4'b1111};}  
                                                    
  constraint csr_adress { csr_addr4 inside {12'hf11,12'hf12,12'hf13,12'hf14,12'h300,12'h301,12'h302,
                                             12'h303,12'h304,12'h305,12'h306,12'h340,12'h341,12'h342,
                                             12'h343,12'h344,12'hb00,12'hb02,12'hb80,12'hb82,12'hc80,
                                             12'hc81,12'hc82,12'hbbf,12'h000,12'h001,12'h002,12'h003,
                                             12'h004,12'h005,12'h040,12'h041,12'h042,12'h043,12'h044,
                                             12'hc00,12'hc01,12'hc02,12'h8ff,12'h100,12'h102,12'h103,
                                             12'h104,12'h105,12'h106,12'h140,12'h141,12'h142,12'h143,
                                             12'h144,12'h180,12'h5C0};} 
                                             
  constraint mode { current_mode inside {2'b00,2'b01,2'b11};}  
  
  function void do_copy (uvm_object rhs);
     t_transaction copied_transaction_h;
    super.do_copy(rhs);
    
   op_a    = copied_transaction_h.op_a;
 	 op_b    = copied_transaction_h.op_b;
	 rd4     = copied_transaction_h.rd4;
	 rs1_4   = copied_transaction_h.rs1_4;
   fn4     = copied_transaction_h.fn4;
	 alu_fn4 = copied_transaction_h.alu_fn4;
   we4     = copied_transaction_h.we4;
   B_imm4  = copied_transaction_h.B_imm4;
	 J_imm4  = copied_transaction_h.J_imm4;
	 U_imm4  = copied_transaction_h.U_imm4;
	 S_imm4  = copied_transaction_h.S_imm4;
   bneq4   = copied_transaction_h.bneq4;
	 btype4  = copied_transaction_h.btype4;
   j4      = copied_transaction_h.j4;
	 jr4     = copied_transaction_h.jr4;
	 LUI4    = copied_transaction_h.LUI4;
	 auipc4  = copied_transaction_h.auipc4;
   mem_op4 = copied_transaction_h.mem_op4;
   
	 mulDiv_op4    = copied_transaction_h.mulDiv_op4; 
   pc4           = copied_transaction_h.pc4;
	 pcselect4     = copied_transaction_h.pcselect4;
	 stall_mem     = copied_transaction_h.stall_mem;
	 dmem_finished = copied_transaction_h.dmem_finished;
	 funct3_4      = copied_transaction_h.funct3_4;
	 csr_data      = copied_transaction_h.csr_data;
	 csr_imm4      = copied_transaction_h.csr_imm4;
	 csr_addr4     = copied_transaction_h.csr_addr4;
	 csr_we4       = copied_transaction_h.csr_we4; 
	 instruction_addr_misaligned4 = copied_transaction_h.instruction_addr_misaligned4;
	 
	 ecall4        = copied_transaction_h.ecall4;
	 ebreak4       = copied_transaction_h.ebreak4;
	 
	 illegal_instr4= copied_transaction_h.illegal_instr4;
	  
	 mret4   = copied_transaction_h.mret4; 
	 sret4   = copied_transaction_h.sret4;
	 uret4   = copied_transaction_h.uret4;
	 m_timer = copied_transaction_h.m_timer;
	 s_timer = copied_transaction_h.s_timer;
	 u_timer = copied_transaction_h.u_timer;
	 
 	 current_mode = copied_transaction_h.current_mode;
	 m_tie = copied_transaction_h.m_tie; 
	 s_tie = copied_transaction_h.s_tie; 
	 m_eie = copied_transaction_h.m_eie; 
	 s_eie = copied_transaction_h.s_eie;
	 u_eie = copied_transaction_h.u_eie;
	 u_tie = copied_transaction_h.u_tie;
	 u_sie = copied_transaction_h.u_sie;
	 external_interrupt = copied_transaction_h.external_interrupt;
	 nrst = copied_transaction_h.nrst;
  endfunction: do_copy  
  
  function t_transaction clone_me ();
    t_transaction clone;
    uvm_object temp;
    temp = this.clone();
    $cast(clone, temp);
    return clone;
 endfunction:clone_me                                                                               
  
endclass:t_transaction
