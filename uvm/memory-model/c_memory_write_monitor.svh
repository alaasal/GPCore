class memory_write_monitor extends uvm_monitor;
    `uvm_component_utils(memory_write_monitor)

    uvm_analysis_port #(memory_write_transaction) memory_write_mon_port;

    uvm_get_port #(memory_write_transaction) memory_write_port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        memory_agent_config memory_agent_config_h;
        memory_write_mon_port = new("addr_ph_port_monitor", this);
        if(!uvm_config_db #(memory_agent_config)::get(this, "", "memory_config", memory_agent_config_h))
            `uvm_fatal("MEMORY_MONITOR", "Failed to get configuration object");
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        memory_write_transaction memory_write_transaction_h;
        string op_name;
        t_mem_addr address;
        t_mem_data data;
        t_write_op write_op;

        forever begin
            memory_write_port.get(memory_write_transaction_h);
            memory_write_mon_port.write(memory_write_transaction_h);
            write_op = memory_write_transaction_h.write_op;
            
            case (write_op)
                WRITE_BYTE: op_name = "WRITE_BYTE";
                WRITE_HALF: op_name = "WRITE_HALF";
                WRITE_FULL:op_name = "WRITE_FULL";
            endcase

            address  = memory_write_transaction_h.address;
            data     = memory_write_transaction_h.data;
            
            `uvm_info("MEMORY_WRITE_MONITOR",$sformatf("MONITOR: OP-NAME: %s  ADDRESS: %2h  DATA: %s", op_name, address, data), UVM_HIGH);
        end
  endtask : run_phase

endclass : memory_write_monitor
