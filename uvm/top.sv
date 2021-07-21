import pkg_main::*;
import pkg_memory::*;
import uvm_pkg::*;
`include"uvm_macros.svh"

//TODO:
/*
    - Simulation Time and Simulation End : DONE
    - Register Connections for log file  : DONE
    - Port Connectionts between monitors
    - Memory Operaions log
*/
`define END 32'h400001A0

module top ();
    timeunit 1ns;

    core_if core_vif();
    reg_if  reg_vif();

    memory_agent_config memory_agent_config_h;
    core_agent_config   core_agent_config_h;
   
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

    //Machine mode
    assign reg_vif.mstatus    =   dut.issue.csr_registers.mstatus;
    assign reg_vif.mip        =   dut.issue.csr_registers.mip;
    assign reg_vif.mie        =   dut.issue.csr_registers.mie;
    assign reg_vif.mtvec      =   {dut.issue.csr_registers.mtvec,2'b0};
    assign reg_vif.mepc       =   dut.issue.csr_registers.mepc;
    assign reg_vif.mcause     =   dut.issue.csr_registers.mcause;
    assign reg_vif.mtval      =   dut.issue.csr_registers.mtval;
    assign reg_vif.mscratch   =   dut.issue.csr_registers.mscratch;
    assign reg_vif.medeleg    =   dut.issue.csr_registers.medeleg_w;
    assign reg_vif.mideleg    =   dut.issue.csr_registers.mideleg_w;
    assign reg_vif.mtimecmp   =   dut.issue.csr_registers.mtimecmp;
    assign reg_vif.mtime      =   dut.issue.csr_registers.mtime;
    //Supervisor mode
    assign reg_vif.sstatus    =   dut.issue.csr_registers.sstatus;
    assign reg_vif.sip        =   dut.issue.csr_registers.sip;
    assign reg_vif.sie        =   dut.issue.csr_registers.sie;
    assign reg_vif.stvec      =   {dut.issue.csr_registers.stvec,2'b0};
    assign reg_vif.sepc       =   dut.issue.csr_registers.sepc;
    assign reg_vif.scause     =   dut.issue.csr_registers.scause;
    assign reg_vif.stval      =   dut.issue.csr_registers.stval;
    assign reg_vif.sscratch   =   dut.issue.csr_registers.sscratch;
    assign reg_vif.sedeleg    =   dut.issue.csr_registers.sedeleg_w;
    assign reg_vif.sideleg    =   dut.issue.csr_registers.sideleg_w;
    assign reg_vif.stimecmp   =   dut.issue.csr_registers.stimecmp;
    //User mod
    assign reg_vif.ustatus    =   dut.issue.csr_registers.ustatus;
    assign reg_vif.uip        =   dut.issue.csr_registers.uip;
    assign reg_vif.uie        =   dut.issue.csr_registers.uie;
    assign reg_vif.utvec      =   {dut.issue.csr_registers.utvec,2'b0};
    assign reg_vif.uepc       =   dut.issue.csr_registers.uepc;
    assign reg_vif.ucause     =   dut.issue.csr_registers.ucause;
    assign reg_vif.utval      =   dut.issue.csr_registers.utval;
    assign reg_vif.uscratch   =   dut.issue.csr_registers.uscratch;
    assign reg_vif.utimecmp   =   dut.issue.csr_registers.utimecmp;
    //Unprivileged register file
    genvar i;
    generate
        for (i=0; i < 32; i++) begin
            assign reg_vif.reg_file[i] = dut.issue.reg1.register[i];
        end
    endgenerate

    assign reg_vif.pc = dut.execute.pcReg5;
	
    initial begin
        $display("creating config objects");

        memory_agent_config_h = new();
        core_agent_config_h   = new(core_vif,reg_vif);

        uvm_config_db #(memory_agent_config)::set(uvm_top,"", "memory_config", memory_agent_config_h);
        uvm_config_db #(core_agent_config)::set(uvm_top ,"", "core_config",core_agent_config_h);
        $display("Starting test");


        run_test("core_test");
    end
endmodule
