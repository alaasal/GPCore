class memory_agent_config;
    //protected uvm_active_passive_enum is_active;
    protected memory memory_h;    //should this be passed to agent?
                        //should it be created in the agent? Nada: yes, Fri 5/8/2021,12:01 am
    string test_name; //something like "arithmetic_test.hex"

    /*function new ( uvm_active_passive_enum is_active);
        this.is_active = is_active; 
    endfunction : new*/
    
    function void set_mem_handle(memory agent_mem_h);
      memory_h = agent_mem_h; 
    endfunction : set_mem_handle
    
    function memory get_mem_handle();
      return memory_h;
    endfunction : get_mem_handle

    /*function uvm_active_passive_enum get_is_active();
        return is_active;
    endfunction : get_is_active*/
endclass : memory_agent_config
