module wrapper(
    input logic clk,
    input logic nrst,

	//OpenPiton Request
	output logic [4:0]   transducer_l15_rqtype,
	output logic [2:0]   transducer_l15_size,
	output logic [31:0]  transducer_l15_address,
	output logic [63:0]  transducer_l15_data,
	output logic         transducer_l15_val,
	input  logic         l15_transducer_ack,
	input  logic         l15_transducer_header_ack,

	//OpenPiton Response
	input  logic        l15_transducer_val,
	input  logic [63:0] l15_transducer_data_0, 
	input  logic [63:0] l15_transducer_data_1, 
	input  logic [31:0] l15_transducer_returntype,
	output logic        transducer_l15_req_ack,

    input  logic        external_interrupt,

    //Machine mode
    output logic [31:0] mstatus,
    output logic [31:0] mip,
    output logic [31:0] mie,
    output logic [31:0] mtvec, 
    output logic [31:0] mepc, 
    output logic [31:0] mcause,
    output logic [31:0] mtval,
    output logic [31:0] mscratch,
    output logic [31:0] medeleg,
    output logic [31:0] mideleg,
    output logic [63:0] mtimecmp,
    output logic [63:0] mtime,
    //Supervisor mode
    output logic [31:0] sstatus,
    output logic [31:0] sip,
    output logic [31:0] sie,
    output logic [31:0] stvec, 
    output logic [31:0] sepc,
    output logic [31:0] scause,
    output logic [31:0] stval,
    output logic [31:0] sscratch,
    output logic [31:0] sedeleg,
    output logic [31:0] sideleg,
    output logic [63:0] stimecmp,
    //User mode
    output logic [31:0] ustatus,
    output logic [31:0] uip,
    output logic [31:0] uie,
    output logic [31:0] utvec,
    output logic [31:0] uepc,
    output logic [31:0] ucause,
    output logic [31:0] utval,
    output logic [31:0] uscratch,
    output logic [63:0] utimecmp,
    output logic [31:0] reg_file [31:0],
    output logic [31:0] pc
);
   core dut(
    .clk                        (clk),
    .nrst                       (nrst),
    .transducer_l15_rqtype      (transducer_l15_rqtype),
    .transducer_l15_size        (transducer_l15_size),
    .transducer_l15_address     (transducer_l15_address),
    .transducer_l15_data        (transducer_l15_data),
    .transducer_l15_val         (transducer_l15_val),
    .l15_transducer_ack         (l15_transducer_ack),
    .l15_transducer_header_ack  (l15_transducer_header_ack),
    .l15_transducer_val         (l15_transducer_val),
    .l15_transducer_data_0      (l15_transducer_data_0),
    .l15_transducer_data_1      (l15_transducer_data_1),
    .l15_transducer_returntype  (l15_transducer_returntype),
    .transducer_l15_req_ack     (transducer_l15_req_ack),
    .external_interrupt         (external_interrupt)
);

    //Machine mode
    assign mstatus    =   dut.issue.csr_registers.mstatus;
    assign mip        =   dut.issue.csr_registers.mip;
    assign mie        =   dut.issue.csr_registers.mie;
    assign mtvec      =   {dut.issue.csr_registers.mtvec,2'b0};
    assign mepc       =   dut.issue.csr_registers.mepc;
    assign mcause     =   dut.issue.csr_registers.mcause;
    assign mtval      =   dut.issue.csr_registers.mtval;
    assign mscratch   =   dut.issue.csr_registers.mscratch;
    assign medeleg    =   dut.issue.csr_registers.medeleg_w;
    assign mideleg    =   dut.issue.csr_registers.mideleg_w;
    assign mtimecmp   =   dut.issue.csr_registers.mtimecmp;
    assign mtime      =   dut.issue.csr_registers.mtime;
    //Supervisor mode
    assign sstatus    =   dut.issue.csr_registers.sstatus;
    assign sip        =   dut.issue.csr_registers.sip;
    assign sie        =   dut.issue.csr_registers.sie;
    assign stvec      =   {dut.issue.csr_registers.stvec,2'b0};
    assign sepc       =   dut.issue.csr_registers.sepc;
    assign scause     =   dut.issue.csr_registers.scause;
    assign stval      =   dut.issue.csr_registers.stval;
    assign sscratch   =   dut.issue.csr_registers.sscratch;
    assign sedeleg    =   dut.issue.csr_registers.sedeleg_w;
    assign sideleg    =   dut.issue.csr_registers.sideleg_w;
    assign stimecmp   =   dut.issue.csr_registers.stimecmp;
    //User mod
    assign ustatus    =   dut.issue.csr_registers.ustatus;
    assign uip        =   dut.issue.csr_registers.uip;
    assign uie        =   dut.issue.csr_registers.uie;
    assign utvec      =   {dut.issue.csr_registers.utvec,2'b0};
    assign uepc       =   dut.issue.csr_registers.uepc;
    assign ucause     =   dut.issue.csr_registers.ucause;
    assign utval      =   dut.issue.csr_registers.utval;
    assign uscratch   =   dut.issue.csr_registers.uscratch;
    assign utimecmp   =   dut.issue.csr_registers.utimecmp;
    //Unprivileged register file
    genvar i;
    generate
        for (i=0; i < 32; i++) begin
            assign reg_file[i] = dut.issue.reg1.register[i];
        end
    endgenerate

    assign pc = dut.execute.pcReg5;

endmodule : wrapper
