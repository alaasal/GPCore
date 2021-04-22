class transaction extends uvm_transation;
    `uvm_object_utils(transaction)

    virtual interface core_if core_vi;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual core_if)::get(null, "*", "core_vi", core_vi))
            $fatal("Failed to connect virtual interface");
    endfunction : build_phase
endclass : transaction
