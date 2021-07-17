import pkg_main::*;
import pkg_memory::*;
import uvm_pkg::*;
`include"uvm_macros.svh"

`define END 32'h400001A0

module top ();

    core_if core_vif();
    reg_if  reg_vif();

   
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
        memory_agent_config memory_agent_config_h = new();
        core_agent_config   core_agent_config_h   = new(core_vif,reg_vif);
        uvm_config_db #(memory_agent_config)::set(uvm_top,"", "memory_config", memory_agent_config_h);
        uvm_config_db #(core_agent_config)::set(uvm_top ,"", "core_config",core_agent_config_h);


        run_test("memory_test");
    end
    
    initial begin
        forever begin
            //Machine mode
            reg_vif.mstatus    =   dut.issue.csr_registers.mstatus;
            reg_vif.mip        =   dut.issue.csr_registers.mip;
            reg_vif.mie        =   dut.issue.csr_registers.mie;
            reg_vif.mtvec      =   {dut.issue.csr_registers.mtvec,2'b0};
            reg_vif.mepc       =   dut.issue.csr_registers.mepc;
            reg_vif.mcause     =   dut.issue.csr_registers.mcause;
            reg_vif.mtval      =   dut.issue.csr_registers.mtval;
            reg_vif.mscratch   =   dut.issue.csr_registers.mscratch;
            reg_vif.medeleg    =   dut.issue.csr_registers.medeleg;
            reg_vif.midleg     =   dut.issue.csr_registers.midleg;
            reg_vif.mtimecmp   =   dut.issue.csr_registers.mtimecmp;
            reg_vif.mtime      =   dut.issue.csr_registers.mtime;
            //Supervisor mode
            reg_vif.sstatus    =   dut.issue.csr_registers.sstatus;
            reg_vif.sip        =   dut.issue.csr_registers.sip;
            reg_vif.sie        =   dut.issue.csr_registers.sie;
            reg_vif.stvec      =   {dut.issue.csr_registers.stvec,2'b0};
            reg_vif.sepc       =   dut.issue.csr_registers.sepc;
            reg_vif.scause     =   dut.issue.csr_registers.scause;
            reg_vif.stval      =   dut.issue.csr_registers.stval;
            reg_vif.sscratch   =   dut.issue.csr_registers.sscratch;
            reg_vif.sedeleg    =   dut.issue.csr_registers.sedeleg;
            reg_vif.sidleg     =   dut.issue.csr_registers.sidleg;
            reg_vif.stimecmp   =   dut.issue.csr_registers.stimecmp;
            //User mod
            reg_vif.ustatus    =   dut.issue.csr_registers.ustatus;
            reg_vif.uip        =   dut.issue.csr_registers.uip;
            reg_vif.uie        =   dut.issue.csr_registers.uie;
            reg_vif.utvec      =   {dut.issue.csr_registers.utvec,2'b0};
            reg_vif.uepc       =   dut.issue.csr_registers.uepc;
            reg_vif.ucause     =   dut.issue.csr_registers.ucause;
            reg_vif.utval      =   dut.issue.csr_registers.utval;
            reg_vif.uscratch   =   dut.issue.csr_registers.uscratch;
            reg_vif.utimecmp   =   dut.issue.csr_registers.utimecmp;
            //Unprivileged register file
            foreach(reg_vif.reg_file[i]) begin
                reg_vif.reg_file[i] = dut.issue.reg1.register[i];
            end
            reg_vif.pc = dut.exe_stage.pcReg5;

        end
    end
  
endmodule
