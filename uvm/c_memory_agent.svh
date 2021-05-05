class memory_agent extends uvm_agent;
    `uvm_component_utils(memory_agent)

    memory_agent_config memory_agent_config_h;

    memory_read    memory_read_h;
    memory_write   memory_write_h;
    memory_monitor memory_monitor_h;

    uvm_tlm_fifo #(memory_read_transaction) memory_read_port;
    uvm_tlm_fifo #(memory_write_transaction) memory_write_port;

    uvm_analysis_port #(memory_read_transaction) memory_read_mon_port;
    uvm_analysis_port #(memory_write_transaction) memory_write_mon_port;
    //TODO: CHECK PORT CONNECTIONS AND MONITORS
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function build_phase(uvm_phase phase);
        if(!uvm_config_db #(memory_agent_config)::get(this, "", "config", memory_agent_config_h));
            `uvm_fatal("MEMORY_AGENT", "Failed to get configuration object");
        
        is_agent = memory_agent_config_h.get_is_active();

        memory_read_h    = memory_read::type_id::create("memory_read_h", this);
        memory_write_h   = memory_write::type_id::create("memory_write_h", this);
        memory_monitor_h = memory_monitor::type_id::create("memory_monitor_h", this);

        memory_read_port  = new("memory_read_port", this);
        memory_write_port = new("memory_write_port", this);

        memory_read_mon_port  = new("memory_read_mon_port", this);
        memory_write_mon_port = new("memory_write_mon_port", this);
    endfunction : build_phase

    function connect_phase(uvm_phase phase);
        memory_read_h.memory_read_port.connect(memory_read_port.get_export);
        memory_write_h.memory_write_port.connect(memory_write_port.get_export);

        memory_monitor_h.memory_write_mon_port.connect(memory_write_mon_port.analysis_export);
        memory_monitor_h.memory_read_mon_port.connect(memory_read_port.analysis_export);
    endfunction : connect_phase

endclass : memory_agent
