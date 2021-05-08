class memory_write extends uvm_driver #(memory_write_transaction);
    `uvm_component_utils(memory_write)

    memory memory_h;
    uvm_get_port #(memory_write_transaction) memory_write_port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        memory_agent_config memory_agent_config_h;
        if(!uvm_config_db #(memory_agent_config)::get(this, "", "config", memory_agent_config_h))
            `uvm_fatal("MEMORY_WRITE", "Failed to get configuration object");
        memory_h = memory_agent_config_h.get_mem_handle();
        memory_write_port = new("memory_write_port", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        memory_write_transaction memory_write_transaction_h;
        t_mem_addr address;
        t_mem_data data;
        t_write_op write_op;

        forever begin
            memory_write_port.get(memory_write_transaction_h);
            write_op = memory_write_transaction_h.write_op;
            address  = memory_write_transaction_h.address;
            data     = memory_write_transaction_h.data;

            case(write_op)
                WRITE_BYTE: memory_h.write_byte(address, data);
                WRITE_HALF: begin
                    memory_h.write_byte(address, data);
                    memory_h.write_byte(address + 1, data);
                end WRITE_FULL: memory_h.write(address, data);
            endcase
        end
    endtask : run_phase
endclass : memory_write