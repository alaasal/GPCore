class exe_monitor extends uvm_monitor#(resp_transaction);
    `uvm_component_utils(exe_monitor)

    virtual interface exe_if vif;

    uvm_put_port #(resp_transaction) tx_port;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
   
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual exe_if)::get(null, "*","vif", vif))
            `uvm_fatal("MONITOR", "Failed to get vif");

        tx_port = new("tx_port", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        monitor();
    endtask : run_phase

    virtual task monitor();
        resp_transaction exe_tx;
        forever begin
            @(negedge clk)
            #1
	        exe_tx.wb_data6 = vif.wb_data6;
	        exe_tx.we6	    = vif.we6;
	        exe_tx.rd6	    = vif.rd6;
	        exe_tx.U_imm6	= vif.U_imm6;
	        exe_tx.AU_imm6	= vif.AU_imm6;
	        exe_tx.mul_divReg6	= vif.mul_divReg6;
	        exe_tx.target	    = vif.target;
	        exe_tx.pc6	        = vif.pc6;
	        exe_tx.pcselect5	= vif.pcselect5;
            //OpenPiton Request
	        exe_tx.mem_l15_rqtype	= vif.mem_l15_rqtype;
	        exe_tx.mem_l15_size	    = vif.mem_l15_size;
	        exe_tx.mem_l15_address	= vif.mem_l15_address;
	        exe_tx.mem_l15_data	    = vif.mem_l15_data;
            exe_tx.mem_l15_val	    = vif.mem_l15_val;
	        //OpenPiton Response
	        exe_tx.l15_mem_data_0	= vif.l15_mem_data_0;
            exe_tx.l15_mem_data_1	= vif.l15_mem_data_1;
	        exe_tx.l15_mem_returntype	= vif.l15_mem_returntype;
            exe_tx.l15_mem_val	        = vif.l15_mem_val;
            exe_tx.l15_mem_ack	        = vif.l15_mem_ack;
	        exe_tx.l15_mem_header_ack	= vif.l15_mem_header_ack;
            exe_tx.mem_l15_req_ack	    = vif.mem_l15_req_ack;
            exe_tx.memOp_done	        = vif.memOp_done;
            exe_tx.ld_addr_misaligned6	= vif.ld_addr_misaligned6;
            exe_tx.samo_addr_misaligned6	= vif.samo_addr_misaligned6;
	        exe_tx.bjtaken6	                = vif.bjtaken6;		//need some debug
	        exe_tx.exception	            = vif.exception;
	        exe_tx.csr_wb	                = vif.csr_wb;
	        exe_tx.csr_wb_addr	            = vif.csr_wb_addr;
	        exe_tx.csr_we6	= vif.csr_we6;
	        // exceptions
	        exe_tx.cause6	            = vif.cause6;
	        exe_tx.exception_pending	= vif.exception_pending;
	        exe_tx.mret6	= vif.mret6; 
            exe_tx.sret6	= vif.sret6;
            exe_tx.uret6	= vif.uret6;
	        exe_tx.m_interrupt	= vif.m_interrupt; 
            exe_tx.s_interrupt	= vif.s_interrupt; 
            exe_tx.u_interrupt	= vif.u_interrupt;
            tx_port.put(exe_tx);
        end
    endtask : drive
   
   
endclass : driver