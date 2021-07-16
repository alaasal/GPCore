import pkg_memory::*;
import uvm_pkg::*;
`include"uvm_macros.svh"

module top ();

    core_if core_vif;
    reg_if  reg_vif;

    core dut(
        .clk                        (core_vif.clk),
        .nrst                       (core_vif.nrst),

        .transducer_l15_rqtype      (core_vif.transducer_l15_rqtype),
	    .transducer_l15_size        (core_vif.transducer_l15_size),
	    .transducer_l15_address     (core_vif.transducer_l15_address),
	    .transducer_l15_data        (core_vif.transducer_l15_data),
	    .transducer_l15_val         (core_vif.transducer_l15_val),
	    .l15_transducer_ack         (core_vif.l15_transducer_ack),
	    .l15_transducer_header_ack  (core_vif.l15_transducer_header_ack),
        .l15_transducer_val         (core_vif.l15_transducer_val),
	    .l15_transducer_data_0      (core_vif.l15_transducer_data_0),
	    .l15_transducer_data_1      (core_vif.l15_transducer_data_1),
	    .l15_transducer_returntype  (core_vif.l15_transducer_returntype),
	    .transducer_l15_req_ack     (core_vif.transducer_l15_req_ack),
        .external_interrupt         (core_vif.external_interrupt)
    );
	
    initial begin
        run_test("memory_test");
    end
  
endmodule
