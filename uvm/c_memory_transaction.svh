class memory_transaction extends uvm_transactions;
    `uvm_object_utils(memory_read_transaction)

    t_mem_addr address;
    t_mem_data data;

    function new(string name);
        super.new(name, parent);
    endfunction : new
endclass : memory_transaction
