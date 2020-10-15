class packet; // used for randomization of variables
  rand bit [6:0] op_rand;
  rand bit [2:0] funct3_rand; 
  rand bit instr_30_rand;
  rand bit [6:0] funct7_rand;
constraint op_range {op_rand inside {7'b 0110011,7'b 0010011, 7'b 1100011, 7'b 1101111, 7'b 1100111, 7'b 0000011, 7'b 0100011, 7'b 0110111}; op_rand == 7'b 1100011 -> funct3_rand > 3'b 000 | 3'b 001 |3'b 100 |3'b 101 |3'b 100 | 3'b 110 | 3'b 111;}
 endclass
	     
module tb_instr_decoder;
reg [6:0] op;
reg [2:0] funct3;
reg instr_30;	        // bit 30 in the instruction
reg [6:0] funct7;

wire [1:0] pcselect;	// select pc source
wire we;	        // regfile write enable
wire [1:0] B_SEL;	// select op b
wire [3:0] alu_fn;	// select alu operation
wire [2:0] fn;		// select result to be written back in regfile
wire bneq,btype;        // to alu beq ~ bneq
wire j, jr, LUI, auipc;        //JAL, JALR,lui,auipc instructions
wire [3:0] mem_op;  //mem operation type
wire [2:0] m_op;
// instantiate device under test
instr_decoder dut( .op(op), .funct7(funct7), .funct3(funct3), .instr_30(instr_30), .pcselect(pcselect), .we(we), .B_SEL(B_SEL), .alu_fn(alu_fn), .fn(fn), .bneq(bneq), .btype(btype) , .jr(jr) , .j(j) , .LUI(LUI) , .auipc(auipc) , .mem_op(mem_op) ,.m_op(m_op) );


// generate cases

initial begin
packet pkt;
pkt = new();
	repeat(10)begin
	 pkt.randomize();
	 op       = pkt.op_rand; 
    	 funct3   = pkt.funct3_rand;      
     	 instr_30 = pkt.instr_30_rand;
	 funct7   = pkt.funct7_rand;
   	 end
end 
endmodule

