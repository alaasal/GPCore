class core_agent extends uvm_agent;
    `uvm_component_utils(core_agent)

    core_driver core_driver_h;
    core_request core_request_h;
    core_monitor core_monitor_h;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        core_driver_h  = core_driver::type_id::create("core_driver_h", this);
        core_request_h = core_request::type_id::create("core_request_h", this);
        core_monitor_h = core_monitor::type_id::create("core_monitor_h", this);
    endfunction : build_phase
endclass : core_agent
 