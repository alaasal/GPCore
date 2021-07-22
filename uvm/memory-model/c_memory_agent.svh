class memory_agent extends uvm_agent;
    `uvm_component_utils(memory_agent)

    memory_agent_config memory_agent_config_h;

    memory_read    memory_read_h;
    memory_write   memory_write_h;
    memory_monitor memory_monitor_h;
    
    memory memory_h;

    uvm_tlm_fifo #(memory_transaction) read_response_to_monitor_fifo;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(memory_agent_config)::get(this, "", "memory_config", memory_agent_config_h))
            `uvm_fatal("MEMORY_AGENT", "Failed to get configuration object");

        memory_h = memory::type_id::create("memory_h", this);
        //Initialize memory
        memory_h.initialize(memory_agent_config_h.test_name);

        memory_agent_config_h.set_mem_handle(memory_h);
        
        memory_read_h    = memory_read::type_id::create("memory_read_h", this);
        memory_write_h   = memory_write::type_id::create("memory_write_h", this);
        memory_monitor_h = memory_monitor::type_id::create("memory_monitor_h", this);

        read_response_to_monitor_fifo  = new("read_response_to_monitor_fifo", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        memory_read_h.monitor_read_respopnse_port.connect(read_response_to_monitor_fifo.put_export);
        memory_monitor_h.monitor_read_respopnse_port.connect(read_response_to_monitor_fifo.get_export);

    endfunction : connect_phase

endclass : memory_agent
