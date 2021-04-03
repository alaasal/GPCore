# See LICENSE for license details.

#include "riscv_test.h"
#undef RVTEST_RV64S
#define RVTEST_RV64S RVTEST_RV32M
#define __MACHINE_MODE

#include "riscv_test.h"
#undef RVTEST_RV64S
#define RVTEST_RV64S RVTEST_RV32S

#*****************************************************************************
# scall.S
#-----------------------------------------------------------------------------
#
# Test syscall trap.
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64S
RVTEST_CODE_BEGIN

#ifdef __MACHINE_MODE
  #define sscratch mscratch
  #define sstatus mstatus
  #define scause mcause
  #define sepc mepc
  #define sret mret
  #define stvec_handler mtvec_handler
#endif

  li TESTNUM, 2

sw:
    la  x1, tdat9
    li  x2, 0x58213098
    addi x1, x1, -3

do_sw:
    sw x2, 7(x1)
    j fail
  

  TEST_PASSFAIL

  .align 2
  .global stvec_handler
stvec_handler:
  li t1, CAUSE_MISALIGNED_STORE
  csrr t0, scause
  bne t0, t1, fail
  la t1, do_sw
  csrr t0, sepc
  bne t0, t1, fail
  j pass

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

tdat:
tdat1:  .word 0xdeadbeef
tdat2:  .word 0xdeadbeef
tdat3:  .word 0xdeadbeef
tdat4:  .word 0xdeadbeef
tdat5:  .word 0xdeadbeef
tdat6:  .word 0xdeadbeef
tdat7:  .word 0xdeadbeef
tdat8:  .word 0xdeadbeef
tdat9:  .word 0xdeadbeef
tdat10: .word 0xdeadbeef

RVTEST_DATA_END