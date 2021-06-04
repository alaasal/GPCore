class memory_transaction extends uvm_transaction;
    `uvm_object_utils(memory_transaction)
    
    protected t_transaction transaction;
    
    function new(string name = "memory_transaction");
        super.new(name);
    endfunction 

    function t_transaction get_transaction(t_memory_op_type source_op);
        if (source_op == transaction.op_type) return transaction;
        else `uvm_fatal("MEMORY_TRANSACTION", "Illegal access to transaction");
    endfunction

    protected function t_transaction get_transaction_protected();
        return transaction;
    endfunction

    function void set_transaction(t_transaction source_transaction);
        transaction = source_transaction;
    endfunction

    function transaction_to_monitor();
        return transaction;
    endfunction

    function get_op_type();
        return transaction.op_type;
    endfunction

    function string convert2string();
        string s;
        string op_type_s, op_size_s;

        op_type_s = (transaction.op_type == READ)? "READ" : "WRITE";
        op_size_s = (transaction.op_size == FULL)? "FULL" : 
                    (transaction.op_size == HALF)? "HALF" : "BYTE";

        s = $sformatf("OP TYPE:\t %s,\n OP SIZE:\t %s,\n ADDRESS:\t %h,\n DATA:\t %h,\n",
                        op_type_s, op_size_s, transaction.address, transaction.data);
        return s;
    endfunction: convert2string

    function void do_copy(uvm_object rhs);
        memory_transaction rhs_;

        if(rhs == null)
            `uvm_fatal("MEMORY_TRANSACTION.do_copy()", "Tried to copy a null pointer");
    
        if (!$cast(rhs_, rhs))
            `uvm_fatal({this.get_name(), ".do_copy()"}, "Cast failed!");

        super.do_copy(rhs);
        this.set_transaction(rhs_.get_transaction_protected());
    endfunction: do_copy

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        memory_transaction rhs_;
        if (rhs == null)
            `uvm_fatal("MEMORY_TRANSACTION.do_compare()", "Tried to copy a null pointer");
        
        if (!$cast(rhs_, rhs))
            `uvm_fatal({this.get_name(), ".do_compare()"}, "Cast failed!");

        do_compare = super.do_compare(rhs, comparer);
        do_compare &= this.transaction == rhs_.get_transaction_protected();
    endfunction: do_compare    

endclass : memory_transaction
