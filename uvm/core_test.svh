class core_test extends uvm_test;
    `uvm_component_utils(core_test)
    
    core_env core_env_h;
   
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      core_env_h = core_env::type_id::create("core_env_h", this);
     
    endfunction
    
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);

     //what TODO??


      phase.drop_objection(this);
      
    endtask
      
  endclass: core_test

