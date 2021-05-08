class memory_transaction extends uvm_transaction;
    `uvm_object_utils(memory_transaction)

    t_mem_addr address;
    t_mem_data data;

    function new(string name = "memory_transaction");
        super.new(name);
    endfunction 
endclass : memory_transaction
