module scoreboard_data_hazards (
input logic clk,nrst,btaken,discard, exception,
//source registers
input logic [4:0] rs1, // instr[15:15]
input logic [4:0] rs2, // instr[23:20]

input logic [4:0] rd,
input logic jr4,

input logic [6:0] op_code,

output logic stall,kill,nostall

);

logic [4:0] scoreboard[0:31];
logic [2:0] function_unit;

logic killReg;
logic [1:0] killnum;


logic stall_wire;



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


          end
          else
	  begin

		
		for(int j=0;j<32;j=j+1)
			begin
		if(scoreboard[j][0] && !scoreboard[j][1])
			 begin
			scoreboard[j][4]<=0;
			scoreboard[j][3]<=0;
			 end

		scoreboard[j][2:0]<={1'b0,scoreboard[j][2:1]};
      	

	end 
	 case(function_unit)
		3'b001:

			begin 	   // pending & write


				if( (|rd)&&  !stall  && !kill)
					begin
					scoreboard[rd][4]<=1; scoreboard[rd][3]<=1;
					scoreboard[rd][2]<=1; 
   					end
				else begin end


			end
		3'b010:
			begin
				if ( (|rd) && (scoreboard[rs1][4] || scoreboard[rs2][4]) && !kill)
				begin



				end
				else if( (|rd)&&  !stall  && !kill)
					begin
					scoreboard[rd][4]<=1; scoreboard[rd][3]<=1;
					scoreboard[rd][2]<=1; 
   					end
				else begin end

			end
		3'b011:
			begin
				if (  (scoreboard[rs1][4] || scoreboard[rs2][4]) && !kill  )
				begin



				end

				else begin end

			end

		3'b100:
			begin
				if ( (|rd) && scoreboard[rs1][4]  && !kill  )
				begin




				end
				else if( (|rd)&&  !stall  && !kill)
					begin
					scoreboard[rd][4]<=1; scoreboard[rd][3]<=1;
					scoreboard[rd][2]<=1;
   					end
				else begin end

			end
		default :
            	begin end
        endcase



	  end
	end

 	always_comb begin
		unique case(op_code)
		7'b0110111: function_unit =3'b001; //lui
		7'b0010111: function_unit =3'b001; //auipc
		7'b1101111: function_unit =3'b001; //jal
		7'b0110011:begin
            function_unit =3'b010;
            stall_wire = (scoreboard[rs1][3] || scoreboard[rs2][3]); /*in commit stage */
			nostall = (scoreboard[rs1][3] || scoreboard[rs2][3]);
        end	//add
		7'b1100011:begin
            function_unit =3'b011;
            stall_wire = (scoreboard[rs1][3] || scoreboard[rs2][3]); /*in commit stage */
			nostall = (scoreboard[rs1][3] || scoreboard[rs2][3]);
        end	//branches
		7'b0100011:begin
            function_unit =3'b011;
            stall_wire = (scoreboard[rs1][3] || scoreboard[rs2][3]);  /*in commit stage */
			nostall = (scoreboard[rs1][3] || scoreboard[rs2][3]);
        end	//stores
		7'b1100111:begin
            function_unit =3'b011;
            stall_wire = (scoreboard[rs1][3] || scoreboard[rs2][3]);
            nostall = (scoreboard[rs1][3] || scoreboard[rs2][3]);
        end	//jalr
		7'b0010011:begin
            function_unit =3'b100;
            stall_wire = (scoreboard[rs1][3]);
            nostall = (scoreboard[rs1][3]);
        end	//addi
		7'b0000011:begin
            function_unit =3'b100;
            stall_wire = (scoreboard[rs1][3]);
            nostall = (scoreboard[rs1][3]);
        end
        7'b1110011:begin //CSR instruction
            function_unit =3'b100;
            stall_wire = (scoreboard[rs1][3]); 
            nostall = (scoreboard[rs1][3]);
        end	//loads

		default: function_unit = 0;
		endcase
	end

assign stall=kill ? 1'b0 :stall_wire;
assign kill= (btaken || killReg || exception ) && ~stall && (~discard)? 1'b1  :1'b0 ;



   always_ff@(posedge clk) begin
if (btaken || exception)
begin

	killReg<=1;
	killnum<=killnum+1;


end
else if (kill && !killnum[1] && killnum[0])
begin

	killReg<=1;
	killnum<=killnum+1;

end
else
begin

	killReg<=0;

end

end

endmodule
