class memory_monitor extends uvm_monitor;
    `uvm_component_utils(memory_monitor)

    uvm_analysis_port #(memory_transaction) monitor_analysis_port;

    uvm_get_port #(memory_transaction) monitor_port;
    uvm_get_port #(memory_transaction) monitor_read_respopnse_port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        monitor_port = new("monitor_port", this);
        monitor_read_respopnse_port = new("monitor_read_respopnse_port", this);
        monitor_analysis_port = new("monitor_analysis_port", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        memory_transaction memory_transaction_h;
 
        forever begin
            memory_port.get(memory_transaction_h);
            if(memory_transaction_h.get_op_type() == READ)
                monitor_read_respopnse_port.get(memory_transaction_h);
            
            `uvm_info(memory_transaction_h.convert2string(), UVM_HIGH);
            monitor_analysis_port.write(memory_read_transaction_h);
        end
  endtask : run_phase
endclass : memory_read_monitor