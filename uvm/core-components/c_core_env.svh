class core_env extends uvm_env;
   `uvm_component_utils(core_env);

    core_agent    core_agent_h;
    memory_agent  memory_agent_h;

    memory_agent_config memory_agent_config_h;
    core_agent_config   core_agent_config_h; 

    virtual interface core_if core_vif;
    virtual interface reg_if reg_vif;

    uvm_tlm_fifo #(memory_transaction) read_response_fifo;
    uvm_tlm_fifo #(memory_transaction) read_request_fifo;
    uvm_tlm_fifo #(memory_transaction) write_request_fifo;

    uvm_tlm_fifo #(memory_transaction) monitor_fifo;

    function new (string name, uvm_component parent);
        super.new(name,parent);
        `uvm_info("core_enc", "Environment created", UVM_LOW)
    endfunction : new


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(virtual core_if)::get(this, "","core_vif", core_vif))
            `uvm_fatal("CORE_ENV", "Failed to get CORE INTERFACE");
        if(!uvm_config_db #(virtual reg_if)::get(this, "","reg_vif", reg_vif))
            `uvm_fatal("CORE_ENV", "Failed to get REGISTER INTERFACE");
        
        memory_agent_config_h = new();
        core_agent_config_h   = new(core_vif,reg_vif);

        memory_agent_config_h.test_name = "diag.hex";

        uvm_config_db #(memory_agent_config)::set(this,"*", "memory_config", memory_agent_config_h);
        uvm_config_db #(core_agent_config)::set(this,"*", "core_config",core_agent_config_h);

        core_agent_h = core_agent::type_id::create("core_agent_h", this);      
        memory_agent_h = memory_agent::type_id::create("memory_agent_h", this); 

        read_response_fifo = new ("read_response_fifo",this);
        read_request_fifo  = new ("read_request_fifo",this);
        write_request_fifo = new ("write_request_fifo",this);

        monitor_fifo       = new("monitor_fifo", this);
    endfunction: build_phase


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
		memory_agent_h.memory_read_h.memory_read_response_port.connect(read_response_fifo.put_export);
		core_agent_h.core_driver_h.memory_read_response_port.connect(read_response_fifo.get_export);

		core_agent_h.core_request_h.memory_read_request_port.connect(read_request_fifo.put_export);
		memory_agent_h.memory_read_h.memory_read_request_port.connect(read_request_fifo.get_export);

		core_agent_h.core_request_h.memory_write_request_port.connect(write_request_fifo.put_export);
		memory_agent_h.memory_write_h.memory_write_port.connect(write_request_fifo.get_export);

        core_agent_h.core_monitor_h.monitor_port.connect(monitor_fifo.put_export);
        memory_agent_h.memory_monitor_h.monitor_port.connect(monitor_fifo.get_export);
    endfunction: connect_phase
endclass : core_env
