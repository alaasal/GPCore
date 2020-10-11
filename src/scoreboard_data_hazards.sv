module scoreboard_data_hazards (
input logic clk,nrst,
//source registers
input logic [4:0] rs1, // instr[16:15]
input logic [4:0] rs2, // instr[24:20]
//destination registers 3,4,5,6
input logic [4:0] rd,
/*input logic [4:0] rd4,
input logic [4:0] rd5,
input logic [4:0] rd6,
*/
input logic [6:0] op_code,
// write enable signals at pipe 3,4,5,6
input logic  we3,
input logic  we4,
input logic  we5,
input logic  we6,

output logic stallout
);

logic re1,re2; // read enable

logic [6:0] scoreboard[0:31];
logic [3:0] function_unit;
logic stall;
logic stallReg;

assign stall = scoreboard[rd][0] /*in commit stage */ ? 1'b0 : 1'b1;  // zeroing pending 

	always_ff @(posedge clk, negedge nrst)
	begin
      	  if (!nrst)
          begin
       		for(int i=0;i<32;i=i+1)
		begin 
			scoreboard[i]<=7'b0;
		end
          end
          else 
	  begin 
		unique case(function_unit)
		4'b0001: 
			begin 	   // pending & write 
				if (scoreboard[rd][6] )  stallReg <= stall; //assign stallo=stallreg
				else 
					begin 
					scoreboard[rd][6]<=1; 
					scoreboard[rd][4]<=1; 
   					end 
			end 
		4'b0010: 
			begin 
				if (scoreboard[rd][6] || scoreboard[rs1][6])  stallReg <= stall; //assign stallo=stallreg
				else 
					begin 
					scoreboard[rd][6]<=1; scoreboard[rs1][6]<=1;
					scoreboard[rd][4]<=1; scoreboard[rs1][4]<=1;
   					end 
			end 
		4'b0011: 
			begin 
				if (scoreboard[rd][6] || scoreboard[rs1][6] || scoreboard[rs2][6])  stallReg <= stall; //assign stallo=stallreg
				else 
					begin 
					scoreboard[rd][6]<=1; scoreboard[rs1][6]<=1;scoreboard[rs2][6]<=1;
					scoreboard[rd][4]<=1; scoreboard[rs1][4]<=1;scoreboard[rs2][4]<=1;
   					end 
			end 
		4'b0100: 
			begin 
				if (scoreboard[rd][6] || scoreboard[rs1][6])  stallReg <= stall; //assign stallo=stallreg
				else 
					begin 
					scoreboard[rd][6]<=1; scoreboard[rs1][6]<=1;
					scoreboard[rd][4]<=1; scoreboard[rs1][4]<=1;
   					end 
			end 
		4'b0101: 
			begin 
				if (scoreboard[rd][6] || scoreboard[rs1][6] || scoreboard[rs2][6])  stallReg <= stall; //assign stallo=stallreg
				else 
					begin 
					scoreboard[rd][6]<=1; scoreboard[rs1][6]<=1;scoreboard[rs2][6]<=1;
					scoreboard[rd][4]<=1; scoreboard[rs1][4]<=1;scoreboard[rs2][4]<=1;
   					end 
			end 
		4'b0110: 
			begin 
				if (scoreboard[rd][6] || scoreboard[rs1][6] || scoreboard[rs2][6])  stallReg <= stall; //assign stallo=stallreg
				else 
					begin 
					scoreboard[rd][6]<=1; scoreboard[rs1][6]<=1;scoreboard[rs2][6]<=1;
					scoreboard[rd][4]<=1; scoreboard[rs1][4]<=1;scoreboard[rs2][4]<=1;
   					end 
			end 
		4'b0111: 
			begin 
				if (scoreboard[rd][6] || scoreboard[rs1][6])  stallReg <= stall; //assign stallo=stallreg
				else 
					begin 
					scoreboard[rd][6]<=1; scoreboard[rs1][6]<=1;
					scoreboard[rd][4]<=1; scoreboard[rs1][4]<=1;
   					end 
			end 
            
        endcase

	  end
	end

 		always_comb
	begin
		unique case(op_code)
			7'b0110111: function_unit =4'b0001 ;			//lui
			7'b0010111: function_unit =4'b0001 ;			//auipc
			7'b1101111: function_unit =4'b0001 ;			//jal
			7'b1100111: function_unit =4'b0010 ;			//jalr
			7'b1100011: function_unit =4'b0011 ;			//branches	
			7'b0000011: function_unit =4'b0100 ;			//loads
			7'b0100011: function_unit =4'b0101 ;			//stores
			7'b0110011: function_unit =4'b0110 ;			//add 
			7'b0010011: function_unit =4'b0111 ;			//addi
				default: function_unit = 0;
		endcase
	end

assign stallout=stallReg;

 always_ff @(negedge clk)
      begin
        for(int j=0;j<32;j=j+1)
	begin 
      	scoreboard[j][4:0]<={1'b0,scoreboard[j][3:0]};
	end
      end
/*
always @(posedge clk)begin // Rtype                   Itype                     Btype
  if(op_code == 7'b 0110011||op_code == 7'b 0010011 || op_code == 7'b 1100011) re1=1;
  else  re1=0;
                   // Rtype                   Btype
  if(op_code == 7'b 0110011|| op_code == 7'b 1100011) re2 = 1;
  else re2 = 0;
    
     // main scoreboard data hazards logic
  if((((rs1==rd)&&we3) || ((rs1==rd4)&&we4) || ((rs1==rd5)&&we5) || ((rs1==rd6)&&we6))&&re1 ||(((rs2==rd)&&we3) ||
     ((rs2==rd4)&&we4) || (((rs2==rd5)&&we5) || ((rs2==rd6)&&we6)))&&re2) stall =1;
    else stall = 0;
end
*/


endmodule
