interface core_if;
    bit clk;
    bit nrst;

	//OpenPiton Request
	bit   [4:0]   transducer_l15_rqtype;
	bit   [2:0]   transducer_l15_size;
	bit   [31:0]  transducer_l15_address;
	bit   [63:0]  transducer_l15_data;
	bit           transducer_l15_val;
	bit           l15_transducer_ack;
	bit           l15_transducer_header_ack;

	//OpenPiton Response
	bit          l15_transducer_val;
	bit   [63:0] l15_transducer_data_0; 
	bit   [63:0] l15_transducer_data_1; 
	bit   [31:0] l15_transducer_returntype;
	bit          transducer_l15_req_ack;

    bit          external_interrupt;

    modport c_if(
        input  clk, nrst,

        output transducer_l15_rqtype, 
        output transducer_l15_size,
        output transducer_l15_address,
	    output transducer_l15_data,
	    output transducer_l15_val,

	    input  l15_transducer_ack,
	    input  l15_transducer_header_ack,

        input l15_transducer_val,
	    input l15_transducer_data_0, 
	    input l15_transducer_data_1, 
	    input l15_transducer_returntype,
	    
        output transducer_l15_req_ack,

        input external_interrupt
    );

    assign l15_transducer_ack = transducer_l15_val;
    
    always #10 clk = ~clk;

    initial begin
        rst = 0;
        l15_transducer_val			<= 0;
		l15_transducer_header_ack 	<= 0;
        @(posedge clk);
        @(posedge clk);
        rst = 1;
        l15_transducer_val			<= 1;
		l15_transducer_header_ack 	<= 0;
		l15_transducer_returntype	<= 4'b0111;
        @(negedge clk);
        l15_transducer_val			<= 0;
		l15_transducer_header_ack 	<= 0;
        @(negedge clk);
        l15_transducer_header_ack 	<= 1;

        forever begin
            @(posedge clk);   
        end
    end

    task put(t_transaction memory_struct);
        @(negedge clk)
        if(memory_struct.op_type == READ) begin
            l15_transducer_ack        = 1;  // response from openpiton to the core
	        l15_transducer_header_ack = 1; // acknowledge that a request is sent

            l15_transducer_val    = 1;
	        {l15_transducer_data_1, l15_transducer_data_0} = memory_struct.data;
	        l15_transducer_returntype = `LOAD_RET;
        end
        @(posedge clk);
    endtask : put

    function memory_transaction get();
        memory_transaction memory_transaction_h;
        memory_transaction_h = memory_transaction::type_id::create("memory_transaction_h", this);
        case(vif.transducer_l15_rqtype)
            `STORE_RQ: tansaction.op_type = WRITE;
            `LOAD_RQ: transaction.op_type = READ;
            default: transaction.op_type  = NOOP;
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
        return memory_transaction_h;
    endfunction : get

endinterface : core_if