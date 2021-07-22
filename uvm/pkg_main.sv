// Requests
`define	LOAD_RQ		4'b0000
`define	STORE_RQ	4'b0001

// Responds
`define LOAD_RET    4'b0000
`define ST_ACK      4'b0100
`define INT_RET     4'b0111

//Message size
`define MSG_DATA_SIZE_WIDTH     3
`define MSG_DATA_SIZE_0B        3'b000
`define MSG_DATA_SIZE_1B        3'b001
`define MSG_DATA_SIZE_2B        3'b010
`define MSG_DATA_SIZE_4B        3'b011

package pkg_main;
    import uvm_pkg::*;
    `include"uvm_macros.svh"

    import pkg_memory::*;

    `include"core-components/c_core_agent_config.svh"
    `include"core-components/c_core_driver.svh"
    `include"core-components/c_core_request.svh"
    `include"core-components/c_core_monitor.svh"
    `include"core-components/c_core_agent.svh"
    `include"core-components/c_core_env.svh"
    `include"core-components/c_core_test.svh"
endpackage