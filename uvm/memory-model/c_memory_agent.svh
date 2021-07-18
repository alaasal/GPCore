class memory_agent extends uvm_agent;
    `uvm_component_utils(memory_agent)

    memory_agent_config memory_agent_config_h;

    memory_read    memory_read_h;
    memory_write   memory_write_h;
    memory_monitor memory_monitor_h;
    
    memory memory_h;

    /*
    uvm_get_port #(memory_transaction) memory_request_to_read_port;
    uvm_get_port #(memory_transaction) memory_request_to_write_port;
    uvm_get_port #(memory_transaction) memory_request_to_monitor_port;
    
    uvm_put_port #(memory_transaction) memory_read_response_port;
    */
    uvm_tlm_fifo #(memory_transaction) read_response_to_monitor_fifo;

    //TODO: CHECK PORT CONNECTIONS AND MONITORS : done
    //TODO: ChANGE TRANSACTION TO ONE TYPE ONLY : done
    //TODO: ADD SCOREBOARD, COVERAGE
    //TODO: CHANGE MONITOR TO ONE TYPE ONLY : done
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(memory_agent_config)::get(this, "", "memory_config", memory_agent_config_h))
            `uvm_fatal("MEMORY_AGENT", "Failed to get configuration object");
        
        //is_active = memory_agent_config_h.get_is_active();
        
        memory_h = memory::type_id::create("memory_h", this);
        //Initialize memory
        memory_h.initialize(memory_agent_config_h.test_name);

        memory_agent_config_h.set_mem_handle(memory_h);
        
        memory_read_h    = memory_read::type_id::create("memory_read_h", this);
        memory_write_h   = memory_write::type_id::create("memory_write_h", this);
        memory_monitor_h = memory_monitor::type_id::create("memory_monitor_h", this);
        
        /*
        memory_request_to_read_port    = new("memory_request_to_read_port", this);
        memory_request_to_write_port   = new("memory_request_to_write_port", this);
        memory_request_to_monitor_port = new("memory_request_to_monitor_port", this);

        memory_read_response_port      = new("memory_read_response_port", this);
        */

        read_response_to_monitor_fifo  = new("read_response_to_monitor_fifo", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        /*
        memory_read_h.memory_read_request_port.connect(memory_request_to_read_port); // recieves request from core
        memory_read_h.memory_read_response_port.connect(memory_read_response_port); // retirns data to core 

        memory_monitor_h.monitor_port.connect(memory_request_to_monitor_port);
        
        memory_write_h.memory_write_port.connect(memory_request_to_write_port);
        */
        
        memory_read_h.monitor_read_respopnse_port.connect(read_response_to_monitor_fifo.put_export);
        memory_monitor_h.monitor_read_respopnse_port.connect(read_response_to_monitor_fifo.get_export);

    endfunction : connect_phase

endclass : memory_agent
