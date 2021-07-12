class memory_agent_config;
    virtual core_if vif;

    function void set_interface(virtual core_if vif);
        this.vif = vif; 
    endfunction : set_interface

    function new(virtual core_if vif);
        set_interface(vif);
    endfunction : new
    
endclass : memory_agent_config