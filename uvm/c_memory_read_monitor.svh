class memory_read_monitor extends uvm_monitor;
    `uvm_component_utils(memory_read_monitor)

    uvm_analysis_port #(memory_read_transaction) memory_read_mon_port;

    uvm_get_port #(memory_read_transaction) memory_read_port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        memory_agent_config memory_agent_config_h;
        memory_read_mon_port = new("addr_ph_port_monitor", this);
        if(!uvm_config_db #(memory_agent_config)::get(this, "", "config", memory_agent_config_h))
            `uvm_fatal("MEMORY_MONITOR", "Failed to get configuration object");
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        memory_read_transaction memory_read_transaction_h;
        memory_read_transaction memory_read_response_transaction_h;
        string op_name;
        t_mem_addr address;
        t_mem_data data;
        t_read_op read_op;

        forever begin
            memory_read_port.get(memory_read_transaction_h);
            memory_read_mon_port.write(memory_read_transaction_h);
            read_op = memory_read_transaction_h.read_op;
            
            case (read_op)
                READ_BYTE: op_name = "READ_BYTE";
                READ_HALF: op_name = "READ_HALF";
                READ_FULL: op_name = "READ_FULL";
            endcase

            address  = memory_read_transaction_h.address;
            data     = memory_read_transaction_h.data;
            
            `uvm_info("MEMORY_READ_MONITOR",$sformatf("MONITOR: OP-NAME: %s  ADDRESS: %2h  DATA: %s", op_name, address, data), UVM_HIGH);
        end
  endtask : run_phase

endclass : memory_read_monitor
