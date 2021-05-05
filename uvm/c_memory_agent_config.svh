class memory_agent_config;
    protected uvm_active_passive_enum is_active;
    memory memory_h;    //should this be passed to agent?
                        //should it be created in the agent?

    function new (memory memory_h, uvm_active_passive_enum is_active);
        this.memory_h  = memory_h;
        this.is_active = is_active; 
    endfunction : new

    function uvm_active_passive_enum get_is_active();
        return is_active;
    endfunction : get_is_active
endclass : memory_agent_config
