class memory_test extends uvm_test;
  `uvm_component_utils(memory_test)
   
    uvm_get_port #(memory_read_transaction)  memory_tst_read_response_port;
    uvm_put_port #(memory_read_transaction)  memory_tst_read_request_port;
    uvm_put_port #(memory_write_transaction) memory_tst_write_port;
    
    memory_agent memory_agent_h;
    memory_agent_config memory_agent_config_h;
    
    memory_read_transaction memory_read_transaction_h;
    memory_write_transaction memory_write_transaction_h;
  function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
  function void build_phase (uvm_phase phase);
    memory_tst_read_response_port = new("memory_tst_read_response_port", this);
    memory_tst_read_request_port  = new("memory_tst_read_request_port", this);
    memory_tst_write_port         = new("memory_tst_write_port", this); 
    
    memory_read_transaction_h = memory_read_transaction::type_id::create("memory_read_transaction_h", this);
    memory_write_transaction_h = memory_write_transaction::type_id::create("memory_write_transaction_h", this);  
    
    // agent
    memory_agent_config_h = new();
    uvm_config_db #(memory_agent_config)::set(this, "memory_agent_h*", "memory_config", memory_agent_config_h);
    memory_agent_h = new("memory_agent_h", this);      
  endfunction : build_phase
  
  function void connect_phase (uvm_phase phase);
     memory_agent_h.memory_read_request_port.connect(memory_tst_read_response_port); // recieves request from core
     memory_agent_h.memory_read_response_port.connect(memory_tst_read_request_port); // retirns data to core 
     memory_agent_h.memory_write_port.connect(memory_tst_write_port);
  endfunction : connect_phase
    
  task run_phase(uvm_phase phase);
    phase.raise_objection();
    memory_write_transaction_h.address = 32'h00;
    memory_write_transaction_h.data = 32'h0badbeef;
    memory_write_transaction_h.write_op = WRITE_FULL;
    memory_tst_write_port.put(memory_write_transaction_h);
    
    memory_read_transaction_h.address = 32'h00;
    memory_read_transaction_h.read_op = READ_FULL;
    memory_tst_read_request_port.put(memory_read_transaction_h);
    
    memory_tst_read_response_port.get(memory_read_transaction_h);
    
    assert(memory_write_transaction_h.data== memory_read_transaction_h.data)else $display("??? ?????");
    phase.drop_objection();
 endtask : run_phase   
  
endclass
