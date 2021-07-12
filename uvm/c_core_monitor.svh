class core_monitor extends uvm_monitor;
    `uvm_components_utils("core_monitor")

    uvm_analysis_port #(memory_transaction) monitor_analysis_port;

    virtual interface core_if vif;
    
    memory_transaction memory_transaction_h;
    t_transaction transaction;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        core_agent_config core_agent_config_h;

        if(!uvm_config_db #(core_agent_config)::get(this, "", "core_config", core_agent_config_h))
            `uvm_fatal("CORE_MONITOR", "Failed to get configuration object");
        
        monitor_analysis_port = new("monitor_analysis_port", this);

        vif = core_agent_config_h.vif;
    endfunction : build_phase 

    task run_phase(uvm_phase phase);
        memory_transaction_h = memory_transaction::type_id::create("memory_transaction_h", this);
        forever begin
            @posedge(clk);
            #1;
            wrap_transaction();
            if(vif.transducer_l15_val == 1) begin
                if((memory_transaction_h.get_op_type() == WRITE) || (memory_transaction_h.get_op_type() == READ)) begin
                    monitor_analysis_port.put(memory_transaction_h);
                end 
            end
        end

    endtask : run_phase

    function wrap_transaction();
        case(vif.transducer_l15_rqtype)
            `STORE_RQ: tansaction.op_type = WRITE;
            `LOAD_RQ: transaction.op_type = READ;
            default: transaction.op_type = NOOP;
        endcase

        if(transaction.op_type != NOOP) begin
            case(vif.transducer_l15_size)
                `MSG_DATA_SIZE_1B: transaction.op_size = BYTE;
                `MSG_DATA_SIZE_2B: transaction.op_size = HALF;
                `MSG_DATA_SIZE_4B: transaction.op_size = FULL;
            endcase

            transaction.address = vif.transducer_l15_address;
            transaction.data = vif.transducer_l15_data;
        end

        memory_transaction_h.set_transaction(transaction);
    endfunction : wrap_transaction
endclass : core_monitor