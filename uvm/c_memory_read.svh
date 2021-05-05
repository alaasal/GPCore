class memory_read extends uvm_driver #(memory_read_transaction);
    `uvm_component_utils(memory_read)

    memory memory_h;
    uvm_get_port #(memory_read_transaction) memory_read_port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        memory_agent_config memory_agent_config_h;
        if(!uvm_config_db #(memory_agent_config)::get(this, "", "config", memory_agent_config_h));
            `uvm_fatal("MEMORY_READ", "Failed to get configuration object");
        memory_h = memory_agent_config_h.memory_h;
        memory_read_port = new("memory_read_port", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        memory_read_transaction memory_read_transaction_h;
        t_mem_addr address;
        t_mem_data data;
        t_read_op read_op;

        forever begin
            memory_read_port.get(memory_read_transaction_h);
            read_op = memory_read_transaction_h.read_op;
            address = memory_read_transaction_h.address;
            data    = 0;

            case(read_op)
                READ_BYTE: data = memory_h.read_byte(address);
                READ_HALF: begin
                    data[0:7] = memory_h.read_byte(address);
                    data[8:15] = memory_h.read_byte(address + 1);
                end READ_FULL: data = memory_h.read(address);
            endcase
            memory_read_transaction_h.data = data;
            memory_read_port.set(memory_read_transaction_h);
        end
    endtask : run_phase
endclass : memory_read
