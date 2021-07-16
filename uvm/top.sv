import pkg_memory::*;
import uvm_pkg::*;
`include"uvm_macros.svh"

module top ();

core_if core_int;

  core dut(
    .clk(core_int.clk),
    .reset(core_int.reset),
       .pc(core_int.pc),
    .instr(core_int.instr));

  
  initial begin
    run_test("memory_test");
  end
  
endmodule
