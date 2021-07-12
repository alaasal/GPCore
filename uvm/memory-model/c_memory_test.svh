class memory_test extends uvm_test;
  `uvm_component_utils(memory_test)
   
    uvm_get_port #(memory_transaction) memory_tst_read_response_port;
    
    uvm_put_port #(memory_transaction) memory_tst_read_request_port;
    uvm_put_port #(memory_transaction) memory_tst_write_port;

    uvm_put_port #(memory_transaction) memory_tst_monitor_port;
    
    memory_agent memory_agent_h;
    memory_agent_config memory_agent_config_h;
    
    memory_transaction memory_transaction_h;

    t_transaction read_transaction;
    t_transaction write_transaction;

    uvm_tlm_fifo #(memory_transaction) read_request_fifo;
    uvm_tlm_fifo #(memory_transaction) write_request_fifo;
    uvm_tlm_fifo #(memory_transaction) monitor_fifo;
    uvm_tlm_fifo #(memory_transaction) read_response_fifo;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    function void build_phase (uvm_phase phase);
        memory_tst_read_response_port = new("memory_tst_read_response_port", this);
        memory_tst_read_request_port  = new("memory_tst_read_request_port", this);
        memory_tst_write_port         = new("memory_tst_write_port", this); 

        memory_tst_monitor_port       = new("memory_tst_monitor_port", this); 

        read_request_fifo = new("read_request_fifo", this); 
        write_request_fifo = new("write_request_fifo", this);
        monitor_fifo       = new("monitor_fifo", this);
        read_response_fifo = new("read_response_fifo", this);

        memory_transaction_h  = memory_transaction::type_id::create("memory_transaction_h", this);  
    
        // agent
        memory_agent_config_h = new();
        uvm_config_db #(memory_agent_config)::set(this, "memory_agent_h*", "memory_config", memory_agent_config_h);
        memory_agent_h = new("memory_agent_h", this);      
    endfunction : build_phase
  
    function void connect_phase (uvm_phase phase);
        memory_agent_h.memory_request_to_read_port.connect(read_request_fifo.get_export); 
        memory_agent_h.memory_read_response_port.connect(read_response_fifo.put_export); 
        memory_agent_h.memory_request_to_write_port.connect(write_request_fifo.get_export);
        memory_agent_h.memory_request_to_monitor_port.connect(monitor_fifo.get_export);

        memory_tst_read_request_port.connect(read_request_fifo.put_export); 
        memory_tst_read_response_port.connect(read_response_fifo.get_export);
        memory_tst_write_port.connect(write_request_fifo.put_export);
        memory_tst_monitor_port.connect(monitor_fifo.put_export);
    endfunction : connect_phase
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        write_transaction.address = 32'h00;
        write_transaction.data    = 32'hdeadbeef;
        write_transaction.op_size = FULL;
        write_transaction.op_type = WRITE;
        memory_transaction_h.set_transaction(write_transaction);
        memory_tst_write_port.put(memory_transaction_h);
        memory_tst_monitor_port.put(memory_transaction_h);    
        #10;
        read_transaction.address = 32'h00;
        read_transaction.data    = 32'hdeadbeef;
        read_transaction.op_size = FULL;
        read_transaction.op_type = READ;
        memory_transaction_h.set_transaction(read_transaction);
        memory_tst_read_request_port.put(memory_transaction_h);
        memory_tst_monitor_port.put(memory_transaction_h); 
    
        memory_tst_read_response_port.get(memory_transaction_h);
    
        assert(write_transaction.data == read_transaction.data)else $display("??? ?????");
        #10;

        
        phase.drop_objection(this);
    endtask : run_phase   
  
endclass
