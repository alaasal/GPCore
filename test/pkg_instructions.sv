//this package contains some written instructions
package pkg_instructions;
    logic [20:1] offset = 20'b1;
    logic [20:1] imm = {offset[20], offset[10:1], offset[11], offset[19:12]};
    logic [4:0] dest = 5'b1; 
    logic [6:0] JAL = 7'b1101111;
    //jalr = {};	//JALR 
    logic [31:0] jal0  = {imm, dest, JAL}; //JAL x0, 1 (unconditional jump)
    //logic [31:0] jal1  = {,};

    logic [6:0] s_opcode = 7'b010_0011;
    logic [6:0] l_opcode = 7'b000_0011;
    logic [6:0] m_opcode = 7'b011_0011;
    /**********************************/
    logic [6:0] m_func7  = 7'b000_0001;
    /**********************************/
    logic [2:0] sw_func = 3'b010;
    logic [2:0] sb_func = 3'b000;
    logic [2:0] sh_func = 3'b001;
    /**********************************/
    logic [2:0] lb_func  = 3'b000;
    logic [2:0] lh_func  = 3'b001;
    logic [2:0] lw_func  = 3'b010;
    logic [2:0] lbu_func = 3'b100;
    logic [2:0] lhu_func = 3'b101;
    /**********************************/
    logic [2:0] mul_func    = 3'b000;
    logic [2:0] mulh_func   = 3'b001;
    logic [2:0] mulhsu_func = 3'b010;
    logic [2:0] mulhu_func  = 3'b011;
    logic [2:0] div_func    = 3'b100;
    logic [2:0] divu_func   = 3'b101;
    logic [2:0] rem_func    = 3'b110;
    logic [2:0] remu_func   = 3'b111; 
    /**********************************/
    logic [11:0] S_imm = 12'h000;
    logic [4:0] rs1  = 5'b00000;
    logic [4:0] rs2  = 1;
    logic [4:0] rs3  = 2;
    logic [4:0] rs4  = 3;
    logic [4:0] rs5  = 4;
    logic [4:0] rs6  = 5;
    logic [4:0] rs7  = 6;
    logic [4:0] rd1  = 20;
    logic [4:0] rd2  = 21;
    logic [4:0] rd3  = 22;
    logic [4:0] rd4  = 23;
    logic [4:0] rd5  = 24;

    logic [31:0] SW = {S_imm[11:5], rs2, rs1, sw_func, S_imm[4:0], s_opcode}; 
    logic [31:0] SB = {S_imm[11:5], rs2, rs1, sb_func, S_imm[4:0], s_opcode};
    logic [31:0] SH = {S_imm[11:5], rs2, rs2, sh_func, S_imm[4:0], s_opcode};

    logic [31:0] LB  ={S_imm, rs1, lb_func, rd1, l_opcode};
    logic [31:0] LH  ={S_imm, rs1, lh_func, rd2, l_opcode};
    logic [31:0] LW  ={S_imm, rs1, lw_func, rd3, l_opcode};
    logic [31:0] LBU ={S_imm, rs1, lbu_func, rd4, l_opcode};
    logic [31:0] LHU ={S_imm, rs1, lhu_func, rd5, l_opcode};

    logic [31:0] MUL    ={m_func7, rs2, rs3, mul_func   , rd1, m_opcode};
    logic [31:0] MULH   ={m_func7, rs4, rs5, mulh_func  , rd1, m_opcode};
    logic [31:0] MULHSU ={m_func7, rs6, rs3, mulhsu_func, rd1, m_opcode};
    logic [31:0] MULHU  ={m_func7, rs3, rs4, mulhu_func , rd1, m_opcode};
    logic [31:0] DIV    ={m_func7, rs3, rs2, div_func   , rd1, m_opcode};
    logic [31:0] DIVU   ={m_func7, rs2, rs3, divu_func  , rd1, m_opcode};
    logic [31:0] REM    ={m_func7, rs5, rs4, rem_func   , rd1, m_opcode};
    logic [31:0] REMU   ={m_func7, rs2, rs3, remu_func  , rd1, m_opcode};
endpackage