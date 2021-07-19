class core_agent extends uvm_agent;
    `uvm_component_utils(core_agent)

    //core_agent_config core_agent_config_h;

    core_driver core_driver_h;
    core_request core_request_h;
    core_monitor core_monitor_h;
    
    /*
    uvm_get_port #(memory_transaction) memory_to_core_response_port;
    uvm_put_port #(memory_transaction) core_to_memory_read_port;
    uvm_put_port #(memory_transaction) core_to_memory_write_port;
    */

    //TODO:

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        core_driver_h  = core_driver::type_id::create("core_driver_h", this);
        core_request_h = core_request::type_id::create("core_request_h", this);
        core_monitor_h = core_monitor::type_id::create("core_monitor_h", this);
        
        /*
        memory_to_core_response_port = new("memory_to_core_response_port", this);
        core_to_memory_read_port     = new("core_to_memory_read_port", this);
        core_to_memory_write_port    = new("core_to_memory_write_port", this);
        */
    endfunction : build_phase
/*
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        core_driver_h.memory_read_response_port.connect(memory_to_core_response_port);

        core_request_h.memory_read_request_port.connect(core_to_memory_read_port);
        core_request_h.memory_write_request_port.connect(core_to_memory_write_port);
        
    endfunction : connect_phase
*/
endclass : core_agent 