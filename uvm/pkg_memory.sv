package pkg_memory;
    import uvm_pkg::*;
    `include"uvm_macros.svh"
  
    parameter XLEN       = 32;
    parameter BYTE_COUNT = XLEN / 8; //byte count
    parameter BYTE_ADDR  = $clog2(BYTE_COUNT); //byte address length

     
    typedef bit [XLEN-1 :0] t_mem_addr;
    typedef bit [XLEN-1 :0] t_mem_data;
    typedef bit [BYTE_COUNT-1 :0][7:0] t_word; //byte addressable word
    typedef bit [pkg_memory::BYTE_ADDR-1 :0] t_byte_addr;

    typedef enum bit[1:0] {BYTE, HALF, FULL} t_op_size;
    typedef enum bit {READ, WRITE} t_memory_op_type;
    
    typedef struct packed{
        t_mem_addr address;
        t_mem_data data;
        t_op_size op_size;
        t_memory_op_type op_type;
    } t_transaction;
    
    `include"c_memory.svh"
    `include"c_memory_transaction.svh"
    //`include"c_memory_read_transaction.svh"
    //`include"c_memory_write_transaction.svh"
    `include"c_memory_agent_config.svh"
    `include"c_memory_read.svh"
    `include"c_memory_write.svh"
    `include"c_memory_monitor.svh"
    //`include"c_memory_write_monitor.svh"
    //`include"c_memory_read_monitor.svh"
    `include"c_memory_agent.svh"
    `include"c_memory_test.svh"
    
endpackage : pkg_memory
