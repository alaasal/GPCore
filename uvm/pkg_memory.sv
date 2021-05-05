package pkg_memory;
    parameter XLEN       = 32;
    parameter BYTE_COUNT = XLEN / 8; //byte count
    parameter BYTE_ADDR  = $clog(BYTE_COUNT); //byte address length

     
    typedef bit [XLEN-1 :0] t_mem_addr;
    typedef bit [XLEN-1 :0] t_mem_data;
    typedef bit [BYTE_COUNT-1 :0][7:0] t_word; //byte addressable word
    typedef bit [pkg_memory::BYTE_ADDR-1 :0] t_byte_addr;

    typedef enum bit[1:0] {WRITE_BYTE, WRITE_HALF, WRTITE_FULL} t_write_op;
    typedef enum bit[1:0] {READ_BYTE,  READ_HALF,  READ_FULL} t_read_op;

endpackage : pkg_memory
