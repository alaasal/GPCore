class memory_write extends uvm_driver #(memory_transaction);
    `uvm_component_utils(memory_write)

    protected t_memory_op_type memory_write_op = WRITE;
    memory memory_h;
    uvm_get_port #(memory_transaction)memory_write_request_port;//////////////////////////////

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        memory_agent_config memory_agent_config_h;
        if(!uvm_config_db #(memory_agent_config)::get(this, "", "memory_config", memory_agent_config_h))
            `uvm_fatal("MEMORY_WRITE", "Failed to get configuration object");
        memory_h = memory_agent_config_h.get_mem_handle();
        memory_write_port = new("memory_write_port", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        memory_transaction memory_write_transaction_h;
        t_transaction memory_write_struct;

        forever begin
            memory_write_port.get(memory_write_transaction_h);
            memory_write_struct = memory_write_transaction_h.get_transaction(memory_write_op);

            case(memory_write_struct.op_size)
                BYTE: memory_h.write_byte(memory_write_struct.address, memory_write_struct.data);
                HALF: begin
                    memory_h.write_byte(memory_write_struct.address, memory_write_struct.data);
                    memory_h.write_byte(memory_write_struct.address + 1, memory_write_struct.data);
                end FULL: memory_h.write(memory_write_struct.address, memory_write_struct.data);
            endcase
        end
    endtask : run_phase
endclass : memory_write