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

    bit          external_interrupt

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

        forever begin
            @(posedge clk);   
        end
    end

endinterface : core_if