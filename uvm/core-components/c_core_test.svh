`define END 32'h400001A0

class core_test extends uvm_test;
    `uvm_component_utils(core_test)
    
    core_env core_env_h;
    virtual interface reg_if reg_vif;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(virtual reg_if)::get(this, "","reg_vif", reg_vif))
            `uvm_fatal("CORE_TEST", "Failed to get REGISTER INTERFACE");
        
        core_env_h = core_env::type_id::create("core_env_h", this);
    endfunction
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        wait (reg_vif.pc === `END);
        phase.drop_objection(this);

    endtask
      
  endclass: core_test
