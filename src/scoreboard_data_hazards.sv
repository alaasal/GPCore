module scoreboard_data_hazards (
input logic clk,nrst,btaken,
//source registers
input logic [4:0] rs1, // instr[15:15]
input logic [4:0] rs2, // instr[23:20]

input logic [4:0] rd,


input logic [6:0] op_code,

output logic stall
);



logic [5:0] scoreboard[0:31];
logic [3:0] function_unit;

logic stallReg;

//assign stall = scoreboard[rd][5] /*in commit stage */ ? 1'b1 : 1'b0;  // zeroing pending 

	always_ff @(negedge clk, negedge nrst)
	begin
      	  if (!nrst)
          begin
       		for(int i=0;i<32;i=i+1)
		begin 
			scoreboard[i]<=7'b0;
			stallReg<=0;
		end
          end
          else 
	  begin 
	 case(function_unit)
		4'b0001: 
			begin 	   // pending & write 
				if ((scoreboard[rd][5])   )  stallReg <= 1; //assign stallo=stallreg
				else    
					begin 
					scoreboard[rd][5]<=1; 
					scoreboard[rd][3]<=1; 
   					end 
				
			end 
		4'b0010: 
			begin 
				if ((scoreboard[rd][5] || scoreboard[rs1][5])  )  stallReg <= 1; //assign stallo=stallreg
				else    
					begin 
					scoreboard[rd][5]<=1; scoreboard[rs1][5]<=1;
					scoreboard[rd][3]<=1; scoreboard[rs1][3]<=1;
   					end 
				
			end 
		4'b0011: 
			begin 
				if (( scoreboard[rs1][5] || scoreboard[rs2][5])  )  stallReg <= 1; //assign stallo=stallreg
				else    
					begin 
					 scoreboard[rs1][5]<=1;scoreboard[rs2][5]<=1;
					 scoreboard[rs1][3]<=1;scoreboard[rs2][3]<=1;
   					end 
				
			end 
		4'b0100: 
			begin 
				if ((scoreboard[rd][5] || scoreboard[rs1][5])  )  stallReg <= 1; //assign stallo=stallreg
				else    
					begin 
					scoreboard[rd][5]<=1; scoreboard[rs1][5]<=1;
					scoreboard[rd][3]<=1; scoreboard[rs1][3]<=1;
   					end 
				
			end 
		4'b0101: 
			begin 
				if ((scoreboard[rd][5] || scoreboard[rs1][5] || scoreboard[rs2][5])  )  stallReg <= 1; //assign stallo=stallreg
				else    
					begin 
					scoreboard[rd][5]<=1; scoreboard[rs1][5]<=1;scoreboard[rs2][5]<=1;
					scoreboard[rd][3]<=1; scoreboard[rs1][3]<=1;scoreboard[rs2][3]<=1;
   					end 
				
			end 
		4'b0110: 
			begin 
				if ((scoreboard[rd][5] || scoreboard[rs1][5] || scoreboard[rs2][5])  )  stallReg <= 1; //assign stallo=stallreg
				else 
					begin 
					scoreboard[rd][5]<=1; scoreboard[rs1][5]<=1;scoreboard[rs2][5]<=1;
					scoreboard[rd][3]<=1; scoreboard[rs1][3]<=1;scoreboard[rs2][3]<=1;
   					end 
				
			end 
		4'b0111: 
			begin 
				if ((scoreboard[rd][5] || scoreboard[rs1][5])  )  stallReg <= 1; //assign stallo=stallreg
				else    
					begin 
					scoreboard[rd][5]<=1; scoreboard[rs1][5]<=1;
					scoreboard[rd][3]<=1; scoreboard[rs1][3]<=1;
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

assign stall=stallReg;

 always_ff @(posedge clk)
      begin
        for(int j=0;j<32;j=j+1)
	begin 
      	scoreboard[j][3:0]<={1'b0,scoreboard[j][3:1]};
	end
	if (stallReg) begin 
	if (!scoreboard[rd][5] && !scoreboard[rs1][5] && !scoreboard[rs2][5]) //depends on instruction
		begin 
		stallReg<=0;
		end
	else begin end 

			end
	else begin end
      end

 always_ff @(negedge clk)
      begin
       for(int j=0;j<32;j=j+1)
	begin 
      	if(scoreboard[j][0])  scoreboard[j][5]<=0;
	else  begin end    
	end
      end


endmodule
