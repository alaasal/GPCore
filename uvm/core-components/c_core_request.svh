class core_request extends uvm_driver #(memory_transaction);
    `uvm_component_utils(core_request)

    uvm_put_port #(memory_transaction) memory_read_request_port;
    uvm_put_port #(memory_transaction) memory_write_request_port;
    core_agent_config core_agent_config_h;
    
    virtual interface core_if vif;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(core_agent_config)::get(this, "", "core_config", core_agent_config_h))
            `uvm_fatal("CORE_Request", "Failed to get configuration object");

        memory_read_request_port = new("memory_read_request_port", this);
        memory_write_request_port = new("memory_write_request_port", this);

        vif = core_agent_config_h.vif;
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        memory_transaction memory_transaction_h;
        t_transaction memory_read_struct;
        memory_transaction_h = memory_transaction::type_id::create("memory_transaction_h", this);
        
        forever begin
            @(negedge vif.clk);
            vif.get(memory_transaction_h); //TODO: Implement get task

            `uvm_info("CORE_REQUEST",memory_transaction_h.convert2string(), UVM_LOW)
            if(memory_transaction_h.get_op_type() == WRITE) begin
                memory_write_request_port.put(memory_transaction_h);
            end else if(memory_transaction_h.get_op_type() == READ) begin
                memory_read_request_port.put(memory_transaction_h);
            end else begin
            end
        end
    endtask : run_phase
endclass : core_request