package pkg_memory;
    parameter XLEN       = 32;
    parameter BYTE_COUNT = XLEN / 8; //byte count
    parameter BYTE_ADDR  = $clog(BYTE_COUNT); //byte address length

     
    typedef bit [XLEN-1 :0] t_mem_addr;
    typedef bit [XLEN-1 :0] t_mem_data;
    typedef bit [BYTE_COUNT-1 :0][7:0] t_word; //byte addressable word
    typedef bit [pkg_memory::BYTE_ADDR-1 :0] t_byte_addr;

endpackage : pkg_memory
