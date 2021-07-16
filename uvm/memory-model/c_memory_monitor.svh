class memory_monitor extends uvm_monitor;
    `uvm_component_utils(memory_monitor)

    uvm_analysis_port #(memory_transaction) monitor_analysis_port;
    uvm_analysis_imp #(memory_transaction , memory_monitor) monitor_import_port;

    uvm_get_port #(memory_transaction) monitor_port;
    uvm_get_port #(memory_transaction) monitor_read_respopnse_port;

    memory_agent_config memory_agent_config_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(memory_agent_config)::get(this, "", "memory_config", memory_agent_config_h))
            `uvm_fatal("MEMORY_MONITOR", "Failed to get configuration object");

        monitor_port = new("monitor_port", this);
        monitor_read_respopnse_port = new("monitor_read_respopnse_port", this);
        monitor_analysis_port = new("monitor_analysis_port", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        memory_transaction memory_transaction_h;
 
        forever begin
            //$display("Monitor");
            monitor_port.get(memory_transaction_h);
            //$display("Monitor1");
            if(memory_transaction_h.get_op_type() == READ)
                monitor_read_respopnse_port.get(memory_transaction_h);
            //$display("Monitor2");
            //$display(memory_transaction_h.convert2string());
            `uvm_info("MEMORY_MONITOR",memory_transaction_h.convert2string(), UVM_LOW)
            //`uvm_info("MEMORY_MONITOR","NADA MOHMAED YOUNIS", UVM_LOW)
            monitor_analysis_port.write(memory_transaction_h);
        end
  endtask : run_phase
endclass : memory_monitor