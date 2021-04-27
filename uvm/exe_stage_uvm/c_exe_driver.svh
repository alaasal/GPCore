class exe_driver extends uvm_driver#(t_transaction);
    `uvm_component_utils(exe_driver)

    virtual interface exe_if vif;

    uvm_get_port #(t_transaction) tx_port;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
   
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual exe_if)::get(null, "*","vif", vif))
            `uvm_fatal("DRIVER", "Failed to get vif");

        tx_port = new("tx_port", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        drive();
    endtask : run_phase

    virtual task drive();
        t_transaction exe_tx;
        forever begin
            tx_port.get(exe_tx);
            @(negedge clk)
            vif.op_a	= exe_tx.op_a;
            vif.op_b	= exe_tx.op_b; 
            vif.rd4	    = exe_tx.op_b;
            vif.rs1_4	= exe_tx.rs1_4;
            vif.fn4	    = exe_tx.fn4;
            vif.alu_fn4	= exe_tx.alu_fn4;
	        vif.we4	    = exe_tx.we4;
            vif.B_imm4	= exe_tx.B_imm4;
            vif.J_imm4	= exe_tx.J_imm4;
            vif.U_imm4	= exe_tx.U_imm4;
            vif.S_imm4	= exe_tx.S_imm4;
            vif.bneq4   = exe_tx.bneq4;
	        vif.btype4	= exe_tx.btype4;
            vif.j4	    = exe_tx.j4;
            vif.jr4	    = exe_tx.jr4;
            vif.LUI4	= exe_tx.LUI4;
            vif.auipc4	= exe_tx.auipc4;
            vif.mem_op4	= exe_tx.mem_op4;
	        vif.mulDiv_op4	= exe_tx.mulDiv_op4;
            vif.pc4	        = exe_tx.pc4;
            vif.pcselect4	= exe_tx.pcselect4;
            vif.stall_mem	= exe_tx.stall_mem;
            vif.dmem_finished	= exe_tx.dmem_finished;
	        vif.funct3_4	= exe_tx.funct3_4;
            vif.csr_data	= exe_tx.csr_data;
            vif.csr_imm4	= exe_tx.csr_imm4;
            vif.csr_addr4	= exe_tx.csr_addr4;
            vif.csr_we4	    = exe_tx.csr_we4;
            vif.instruction_addr_misaligned4	= exe_tx.instruction_addr_misaligned4;
	        vif.ecall4	        = exe_tx.ecall4;
            vif.ebreak4	        = exe_tx.ebreak4;
            vif.illegal_instr4	= exe_tx.illegal_instr4;
	        vif.mret4	= exe_tx.mret4;
            vif.sret4	= exe_tx.sret4;
            vif.uret4	= exe_tx.uret4;
            vif.m_timer	= exe_tx.m_timer;
            vif.s_timer	= exe_tx.s_timer;
            vif.u_timer	= exe_tx.u_timer;
 	        vif.current_mode	= exe_tx.current_mode;
            vif.m_tie	= exe_tx.m_tie;
            vif.s_tie	= exe_tx.s_tie;
            vif.m_eie	= exe_tx.m_eie;
            vif.s_eie	= exe_tx.s_eie;
            vif.u_eie	= exe_tx.u_eie;
            vif.u_tie	= exe_tx.u_tie;
            vif.u_sie	= exe_tx.u_sie;
            vif.external_interrupt	= exe_tx.external_interrupt;
        end
    endtask : drive
   
   
endclass : driver