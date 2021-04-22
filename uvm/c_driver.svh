class core_driver extends uvm_component;
    `uvm_component_utils(core_driver)

    virtual interface core_if core_vi;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual core_if)::get(null, "*", "core_vi", core_vi))
            $fatal("Failed to connect virtual interface");
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        
    endtask : run_phase


endclass