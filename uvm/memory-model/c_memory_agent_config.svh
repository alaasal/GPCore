class memory_agent_config;
    protected memory memory_h;    

    string test_name; 
 
    function void set_mem_handle(memory agent_mem_h);
      memory_h = agent_mem_h; 
    endfunction : set_mem_handle
    
    function memory get_mem_handle();
      return memory_h;
    endfunction : get_mem_handle
endclass : memory_agent_config
