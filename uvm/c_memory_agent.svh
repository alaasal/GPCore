class memory_agent extends uvm_agent;
    `uvm_component_utils(memory_agent)

    memory_agent_config memory_agent_config_h;

    memory_read    memory_read_h;
    memory_write   memory_write_h;
    memory_write_monitor memory_write_monitor_h;
    memory_read_monitor memory_read_monitor_h;
    
    memory memory_h;

    uvm_get_port #(memory_read_transaction) memory_read_request_port;
    uvm_put_port #(memory_read_transaction) memory_read_response_port;
    uvm_get_port #(memory_write_transaction) memory_write_port;

    //uvm_analysis_port #(memory_read_transaction) memory_read_mon_port;
    //uvm_analysis_port #(memory_write_transaction) memory_write_mon_port;
    //TODO: CHECK PORT CONNECTIONS AND MONITORS : done
    //TODO: ChANGE TRANSACTION TO ONE TYPE ONLY
    //TODO: ADD SCOREBOARD, COVERAGE
    //TODO: CHANGE MONITOR TO ONE TYPE ONLY
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(memory_agent_config)::get(this, "", "memory_config", memory_agent_config_h))
            `uvm_fatal("MEMORY_AGENT", "Failed to get configuration object");
        
        //is_active = memory_agent_config_h.get_is_active();
        
        memory_h = memory::type_id::create("memory_h", this);
        memory_agent_config_h.set_mem_handle(memory_h);
        
        memory_read_h    = memory_read::type_id::create("memory_read_h", this);
        memory_write_h   = memory_write::type_id::create("memory_write_h", this);
        //memory_write_monitor_h = memory_write_monitor::type_id::create("memory_write_monitor_h", this);
        //memory_read_monitor_h  = memory_read_monitor::type_id::create("memory_read_monitor_h", this);

        memory_read_request_port  = new("memory_read_request_port", this);
        memory_read_response_port = new("memory_read_response_port", this);
        memory_write_port         = new("memory_write_port", this);

        //memory_read_mon_port  = new("memory_read_mon_port", this);
        //memory_write_mon_port = new("memory_write_mon_port", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        memory_read_h.memory_read_request_port.connect(memory_read_request_port); // recieves request from core
        memory_read_h.memory_read_response_port.connect(memory_read_response_port); // retirns data to core 
        
        memory_write_h.memory_write_port.connect(memory_write_port);
        /*
        memory_write_monitor_h.memory_write_mon_port.connect(memory_write_mon_port.analysis_export);
        memory_read_monitor_h.memory_read_mon_port.connect(memory_read_mon_port.analysis_export);
        */
    endfunction : connect_phase

endclass : memory_agent
