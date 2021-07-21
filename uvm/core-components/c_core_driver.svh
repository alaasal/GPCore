class core_driver extends uvm_driver #(memory_transaction);
    `uvm_component_utils(core_driver)

    protected t_memory_op_type memory_read_op = READ;

    uvm_get_port #(memory_transaction) memory_read_response_port;
    
    virtual interface core_if vif;
    core_agent_config core_agent_config_h;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(core_agent_config)::get(this, "", "core_config", core_agent_config_h))
            `uvm_fatal("CORE_DRIVER", "Failed to get configuration object")

        memory_read_response_port = new("memory_read_response_port", this);
        vif = core_agent_config_h.vif;
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        memory_transaction memory_read_transaction_h;
        t_transaction memory_read_struct;

        forever begin
            $display("before get");
            memory_read_response_port.get(memory_read_transaction_h);
            $display("after get");
            memory_read_struct = memory_read_transaction_h.get_transaction(memory_read_op);
             `uvm_info("CORE_driver",memory_read_transaction_h.convert2string(), UVM_LOW)
            vif.put(memory_read_struct); //TODO: Implement put task        
        end
    endtask : run_phase
endclass : core_driver