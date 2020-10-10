module scoreboard_data_hazards (
input logic clk,
//source registers
input logic [4:0] rs1, // instr[19:15]
input logic [4:0] rs2, // instr[24:20]
//destination registers 3,4,5,6
input logic [4:0] rd3,
input logic [4:0] rd4,
input logic [4:0] rd5,
input logic [4:0] rd6,

input logic [6:0] op_code,
// write enable signals at pipe 3,4,5,6
input logic  we3,
input logic  we4,
input logic  we5,
input logic  we6,

output logic stall
);

logic re1,re2; // read enable

always @(posedge clk)begin // Rtype                   Itype                     Btype
  if(op_code == 7'b 0110011||op_code == 7'b 0010011 || op_code == 7'b 1100011) re1=1;
  else  re1=0;
                   // Rtype                   Btype
  if(op_code == 7'b 0110011|| op_code == 7'b 1100011) re2 = 1;
  else re2 = 0;
    
     // main scoreboard data hazards logic
  if((((rs1==rd3)&&we3) || ((rs1==rd4)&&we4) || ((rs1==rd5)&&we5) || ((rs1==rd6)&&we6))&&re1 ||(((rs2==rd3)&&we3) ||
     ((rs2==rd4)&&we4) || (((rs2==rd5)&&we5) || ((rs2==rd6)&&we6)))&&re2) stall =1;
    else stall = 0;
end

endmodule
