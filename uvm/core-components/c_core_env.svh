class core_env extends uvm_env;
   `uvm_component_utils(core_env);

    core_agent    core_agent_h;
    memory_agent  memory_agent_h;

    uvm_tlm_fifo #(transaction) read_response_fifo;
    uvm_tlm_fifo #(transaction) read_request_fifo;
    uvm_tlm_fifo #(transaction) write_request_fifo;


    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new


    function void build_phase(uvm_phase phase);
        core_agent_h = core_agent::type_id::create("core_agent_h", this);      
        memory_agent_h = memory_agent::type_id::create("memory_agent_h", this); 

        read_response_fifo = new ("read_response_fifo",this);
        read_request_fifo  = new ("read_request_fifo",this);
        write_request_fifo = new ("write_request_fifo",this);
    endfunction: build_phase


    function void connect_phase(uvm_phase phase);
		core_agent_h.core_monitor_h.monitor_analysis_port.connect(memory_agent_h.memory_request_to_monitor_port);

		memory_agent_h.memory_read_response_port.connect(read_response_fifo.put_export());
		core_agent_h.memory_to_core_response_port.connect(read_response_fifo.get_export());

		core_agent_h.core_to_memory_read_port.connect(read_response_fifo.put_export());
		memory_agent_h.memory_request_to_read_port.connect(read_request_fifo.get_export());

		core_agent_h.core_to_memory_write_port.connect(write_response_fifo.put_export());
		memory_agent_h.memory_request_to_write_port.connect(write_request_fifo.get_export());
    endfunction: connect_phase
endclass : core_env
