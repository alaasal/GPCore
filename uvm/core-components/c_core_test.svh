`define END 32'h400001A0

class core_test extends uvm_test;
    `uvm_component_utils(core_test)
    
    core_env core_env_h;
    virtual interface reg_if reg_vif;
    core_agent_config core_agent_config_h;
   
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        core_env_h = core_env::type_id::create("core_env_h", this);

        if(!uvm_config_db #(core_agent_config)::get(this, "", "core_config", core_agent_config_h))
            `uvm_fatal("CORE_TEST", "Failed to get configuration object");
    endfunction
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        while(reg_vif.pc != `END);
        phase.drop_objection(this);

    endtask
      
  endclass: core_test
