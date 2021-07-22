interface reg_if;
    //Machine mode
    logic [31:0] mstatus;
    logic [31:0] mip;
    logic [31:0] mie;

    logic [31:0] mtvec; 
    logic [31:0] mepc; 

    logic [31:0] mcause;
    logic [31:0] mtval;
    logic [31:0] mscratch;

    logic [31:0] medeleg;
    logic [31:0] mideleg;

    logic [63:0] mtimecmp;
    logic [63:0] mtime;

    //Supervisor mode
    logic [31:0] sstatus;
    logic [31:0] sip;
    logic [31:0] sie;

    logic [31:0] stvec;
    logic [31:0] sepc; 

    logic [31:0] scause;
    logic [31:0] stval;
    logic [31:0] sscratch;
    
    logic [31:0] sedeleg;
    logic [31:0] sideleg;

    logic [63:0] stimecmp;

    //User mode
    logic [31:0] ustatus;
    logic [31:0] uip;
    logic [31:0] uie;

    logic [31:0] utvec;
    logic [31:0] uepc;

    logic [31:0] ucause;
    logic [31:0] utval;
    logic [31:0] uscratch;

    logic [63:0] utimecmp;

    logic [31:0] reg_file [31:0];

    logic [31:0] pc;
    
    function string convert2string();
        string s0;
        string s;
        string s2;
        string s3;
        string s4;
        s4 = "";
        s0 = $sformatf("%h,", pc);
        s = $sformatf("%h, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h,",
            mstatus, mip, mie, mtvec, mepc, mcause, mtval, mscratch, medeleg, mideleg, mtimecmp, mtime);
    
        s2 = $sformatf("%h, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h,",
            sstatus, sip, sie, stvec, sepc, scause, stval, sscratch, sedeleg, sideleg, stimecmp);

        s3 = $sformatf("%h, %h, %h, %h, %h, %h, %h, %h, %h,",
            ustatus, uip, uie, utvec, uepc, ucause, utval, uscratch, utimecmp);

        foreach(reg_file[i]) begin
            s4 = {s4, $sformatf("%h,", reg_file[i])};
        end

        return {s0, s4, s, s2, s3};
    endfunction : convert2string
 
endinterface : reg_if
