import pkg_main::*;
import pkg_memory::*;
import uvm_pkg::*;
`include"uvm_macros.svh"

`define END 32'h400001A0

module top ();
    timeunit 1ns;

    core_if core_vif();
    reg_if  reg_vif();

    memory_agent_config memory_agent_config_h;
    core_agent_config   core_agent_config_h;
   
    wrapper dut(
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
        .external_interrupt         (core_vif.external_interrupt),
        //Machine mode
        .mstatus                    (reg_vif.mstatus),
        .mip                        (reg_vif.mip),
        .mie                        (reg_vif.mie),
        .mtvec                      (reg_vif.mtvec),
        .mepc                       (reg_vif.mepc), 
        .mcause                     (reg_vif.mcause),
        .mtval                      (reg_vif.mtval),
        .mscratch                   (reg_vif.mscratch),
        .medeleg                    (reg_vif.medeleg),
        .mideleg                    (reg_vif.mideleg),
        .mtimecmp                   (reg_vif.mtimecmp),
        .mtime                      (reg_vif.mtime),
        //Supervisor mode
        .sstatus                    (reg_vif.sstatus),
        .sip                        (reg_vif.sip),
        .sie                        (reg_vif.sie),
        .stvec                      (reg_vif.stvec), 
        .sepc                       (reg_vif.sepc),
        .scause                     (reg_vif.scause),
        .stval                      (reg_vif.stval),
        .sscratch                   (reg_vif.sscratch),
        .sedeleg                    (reg_vif.sedeleg),
        .sideleg                    (reg_vif.sideleg),
        .stimecmp                   (reg_vif.stimecmp),
        //User mode
        .ustatus                    (reg_vif.ustatus),
        .uip                        (reg_vif.uip),
        .uie                        (reg_vif.uie),
        .utvec                      (reg_vif.utvec),
        .uepc                       (reg_vif.uepc),
        .ucause                     (reg_vif.ucause),
        .utval                      (reg_vif.utval),
        .uscratch                   (reg_vif.uscratch),
        .utimecmp                   (reg_vif.utimecmp),
        .reg_file                   (reg_vif.reg_file),
        .pc                         (reg_vif.pc)
    );

    initial begin
        uvm_config_db #(virtual core_if)::set(uvm_top, "", "core_vif", core_vif);
        uvm_config_db #(virtual reg_if)::set(uvm_top, "", "reg_vif", reg_vif);

        run_test("core_test");
    end
endmodule
