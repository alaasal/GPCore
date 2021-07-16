class memory_agent_config;
    virtual core_if vif;
    virtual reg_if reg_vif;

    function void set_interface(virtual core_if vif, virtual reg_if reg_vif);
        this.vif     = vif; 
        this.reg_vif = reg_vif; 
    endfunction : set_interface

    function new(virtual core_if vif, , virtual reg_if reg_vif);
        set_interface(vif, reg_vif);
    endfunction : new
    
endclass : memory_agent_config