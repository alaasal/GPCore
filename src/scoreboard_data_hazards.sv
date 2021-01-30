module scoreboard_data_hazards (
input logic clk,nrst,btaken,
//source registers
input logic [4:0] rs1, // instr[15:15]
input logic [4:0] rs2, // instr[23:20]

input logic [4:0] rd,


input logic [6:0] op_code,

output logic stall,kill,
output logic [1:0] stallnum
);



logic [4:0] scoreboard[0:31];
logic [2:0] function_unit;

logic killReg;
logic [1:0] killnum;

logic stall_wire;
logic kill_wire;


	always_ff @(posedge clk, negedge nrst)
	begin
      	  if (!nrst)
          begin
       		for(int i=0;i<32;i=i+1)
		begin 
			scoreboard[i]<=7'b0;
			
		end
	killnum<=2'b0;
	killReg <=0;
	stallnum<=0;
          end
          else 
	  begin 
	 case(function_unit)
		4'b001: 

			begin 	   // pending & write 
				
//something to be done
				if( (|rd)&&  !stall  && !kill)   
					begin 
					scoreboard[rd][4]<=1; scoreboard[rd][3]<=1;
					scoreboard[rd][2]<=1; 
   					end 
				else begin end 
				
				
			end 
		4'b010: 
			begin 
				if ((scoreboard[rs1][4]) && (|rd) && scoreboard[rs1][3] && !kill)   
				begin
				
				if (!stallnum[1] && stallnum[0]) stallnum<= 2'b00;
				else begin end

				end
				else if( (|rd)&&  !stall  && !kill)   
					begin 
					scoreboard[rd][4]<=1; scoreboard[rd][3]<=1;
					scoreboard[rd][2]<=1; 
   					end 
				else begin end 
				
			end 
		4'b011: 
			begin 
				if (  (scoreboard[rs1][4] || scoreboard[rs2][4]) &&(scoreboard[rs1][3] || scoreboard[rs2][3]) && !kill  )   
				begin
				
				if (!stallnum[1] && stallnum[0]) stallnum<= 2'b00;
				else begin end

				end
				
				else begin end 
				
			end 
		4'b100: 
			begin 
				if ((scoreboard[rs1][4]) && (|rd) && scoreboard[rs1][3] && !kill)  
				begin
				 
				if (!stallnum[1] && stallnum[0]) stallnum<= 2'b00;
				else begin end

				end
				else if( (|rd) && !stall && !kill)   
					begin 
					scoreboard[rd][4]<=1; scoreboard[rd][3]<=1;
					scoreboard[rd][2]<=1; 
   					end 
				else begin end 
				
			end 
		4'b101: 
			begin 
				if ((  scoreboard[rs1][4] || scoreboard[rs2][4] ) && (scoreboard[rs1][3] || scoreboard[rs2][3]) && !kill  )  
				begin
				
				if (!stallnum[1] && stallnum[0]) stallnum<= 2'b00;
				else begin end


				end
				
				else begin end 
				
			end 
		4'b110: 
			begin 
				if (( scoreboard[rs1][4] || scoreboard[rs2][4] ) && (scoreboard[rs1][3] || scoreboard[rs2][3])&& (|rd) && !kill)  
				begin
				
				if (!stallnum[1] && stallnum[0]) stallnum<= 2'b00;
				else begin end


				end
				else if( !stall && (|rd) && !kill)
					begin 
					scoreboard[rd][4]<=1;scoreboard[rd][3]<=1;
					scoreboard[rd][2]<=1; 
   					end 
				else begin end
				
					
				
			end 
		default :
            	begin end
        endcase

	  end
	end

 		always_comb
	begin
		unique case(op_code)
			7'b0110111:begin  function_unit =3'b001 ;		end 	//lui
			7'b0010111:begin function_unit =3'b001 ;		end	//auipc
			7'b1101111:begin function_unit =3'b001 ;		end	//jal
			7'b1100111:begin function_unit =3'b010 ;	assign stall_wire = (scoreboard[rs1][3] && ~scoreboard[rs1][2])  /*in commit stage */ ? 1'b1 : 1'b0; 	end	//jalr
			7'b0010011:begin function_unit =3'b010 ;	assign stall_wire = (scoreboard[rs1][3]&& ~scoreboard[rs1][2])  /*in commit stage */ ? 1'b1 : 1'b0; 	end	//addi
			7'b1100011:begin function_unit =3'b011 ;	assign stall_wire = ((scoreboard[rs1][3] && ~scoreboard[rs1][2] || scoreboard[rs2][3]) && ~scoreboard[rs1][2])  /*in commit stage */ ? 1'b1 : 1'b0; 	end	//branches	
			7'b0000011:begin function_unit =3'b100 ;	assign stall_wire = (scoreboard[rs1][3] )  /*in commit stage */ ? 1'b1 : 1'b0;    end	//loads
			7'b0100011:begin function_unit =3'b101 ;	assign stall_wire = ((scoreboard[rs1][3]  || scoreboard[rs2][3]) && ~scoreboard[rs1][2])  /*in commit stage */ ? 1'b1 : 1'b0; 	end	//stores
			7'b0110011:begin function_unit =3'b110 ;	assign stall_wire = ((scoreboard[rs1][3]  || scoreboard[rs2][3]) && ~scoreboard[rs1][2])  /*in commit stage */ ? 1'b1 : 1'b0; 	end	//add 
			
				default: function_unit = 0;
		endcase
	end

assign stall=kill ? 1'b0 :stall_wire;
assign kill= btaken || killReg? 1'b1   :1'b0 ;

 always_ff @(posedge clk)
      begin
        for(int j=0;j<32;j=j+1)
	begin 
if(scoreboard[j][0] && !scoreboard[j][1]) 
	 begin 
	scoreboard[j][4]=0;   
	scoreboard[j][3]=0; 
	 end 
      	scoreboard[j][2:0]={1'b0,scoreboard[j][2:1]};
	
	end
	if (stall_wire) begin 
	
				
				 if(scoreboard[rs1][2]) stallnum<= 2'b11;
				else if(scoreboard[rs1][1]) stallnum<= 2'b10;
				else if(scoreboard[rs1][0]) stallnum<= 2'b01;
				else begin end
				
				
				 if(scoreboard[rs2][2]) stallnum<= 2'b11;
				else if(scoreboard[rs2][1]) stallnum<= 2'b10;
				else if(scoreboard[rs2][0]) stallnum<= 2'b01;
				else begin end

		end
	else begin end
	
      end

 always_ff @(posedge clk)
      begin
       for(int j=0;j<32;j=j+1)
	begin 
      
	  
	end
      end
   always_ff@(posedge clk) begin 
if (btaken)
begin 
	//stallReg<=0; waiting test
	killReg<=1;
	killnum=killnum+1;
	scoreboard[rd][4]<=0; scoreboard[rd][3]<=0;
	scoreboard[rd][2]<=0;

end
else if (!killnum[1] && killnum[0])
begin 
	//stallReg<=0; waiting test
	killReg<=1;
	killnum=killnum+1;

end 
else 
begin 

	killReg<=0;

end

end 

endmodule
