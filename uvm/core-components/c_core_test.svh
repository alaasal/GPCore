`define END 32'h400001A0

class core_test extends uvm_test;
    `uvm_component_utils(core_test)
    
    core_env core_env_h;
    virtual interface reg_if reg_vif;
    
    core_agent_config core_agent_config_h;
    memory_agent_config memory_agent_config_h;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        `uvm_info("core_test", "Test created", UVM_LOW)
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("core_test", "build", UVM_LOW)
        core_env_h = core_env::type_id::create("core_env_h", this);

        if(!uvm_config_db #(core_agent_config)::get(this, "", "core_config", core_agent_config_h))
            `uvm_fatal("CORE_TEST", "Failed to get configuration object");

        if(!uvm_config_db #(memory_agent_config)::get(this, "", "memory_config", memory_agent_config_h))
            `uvm_fatal("CORE_TEST", "Failed to get configuration object");

        reg_vif = core_agent_config_h.reg_vif;
        memory_agent_config_h.test_name = "diag.hex";
        `uvm_info("core_test", "end of build", UVM_LOW)
    endfunction
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        while(reg_vif.pc != `END);
        phase.drop_objection(this);

    endtask
      
  endclass: core_test
