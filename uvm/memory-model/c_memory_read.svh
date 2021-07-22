class memory_read extends uvm_driver #(memory_transaction);
    `uvm_component_utils(memory_read)

    protected t_memory_op_type memory_read_op = READ;
    memory memory_h;
    uvm_get_port #(memory_transaction) memory_read_request_port;
    uvm_put_port #(memory_transaction) memory_read_response_port;
    uvm_put_port #(memory_transaction) monitor_read_respopnse_port;

    memory_agent_config memory_agent_config_h;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        

        if(!uvm_config_db #(memory_agent_config)::get(this, "", "memory_config", memory_agent_config_h))
            `uvm_fatal("MEMORY_READ_DRIVER", "Failed to get configuration object");
        memory_h = memory_agent_config_h.get_mem_handle();

        memory_read_request_port    = new("memory_read_request_port", this);
        memory_read_response_port   = new("memory_read_response_port", this);
        monitor_read_respopnse_port = new("monitor_read_respopnse_port", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        memory_transaction memory_read_transaction_h;
        t_transaction memory_read_struct;

        forever begin
            memory_read_request_port.get(memory_read_transaction_h);
            memory_read_struct = memory_read_transaction_h.get_transaction(memory_read_op);
            
            memory_read_struct.data = memory_h.read(memory_read_struct.address);

            memory_read_transaction_h.set_transaction(memory_read_struct);
            fork 
                begin
                    monitor_read_respopnse_port.put(memory_read_transaction_h);
                end
                begin
                    memory_read_response_port.put(memory_read_transaction_h);
                end
            join_none
            
        end
    endtask : run_phase
endclass : memory_read
