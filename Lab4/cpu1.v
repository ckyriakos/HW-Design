

module CPU(clock,reset);

input clock,reset;
wire [31:0] pc_in,pc_out,alu_out;
wire zero ; 
wire[31:0] im_out ,dout,out;
wire [31:0] rdA,rdB,sign_out;
wire[1:0]  ALUop;
wire RegWrite,RegDst,AluSrc,Branch,MemWrite,MemToReg,MemRead;
wire [31:0] mux1,mux3,mux4;
wire [4:0] mux2;
wire [3:0] ALUcontrol ; 
wire  random ;
wire [3:0] opzero ;
assign opzero = 4'b0010 ;

PC pc(reset,clock,mux1,pc_out);

add add_pc(pc_out,pc_in);

Instruction_mem cpu_IMem(pc_out,im_out);

Control ctrl(im_out[31:26],RegWrite,RegDst,MemRead,AluSrc,Branch,MemWrite,MemToReg,ALUop);

ALUControl aluctr(ALUop,im_out[5:0],ALUcontrol);

ALU alu(out, zero, rdA, mux3, ALUcontrol);
 
RegFile cpu_regs(clock, reset, im_out[25:21], im_out[20:16], mux2, RegWrite, mux4, rdA, rdB);

sign_extend sign(im_out[15:0],sign_out);

Memory   DMem(MemRead,MemWrite,out, rdB, dout);

ALU add_alu(alu_out,random,pc_in,sign_out<<2,opzero);


 assign mux1 = (Branch && zero)?alu_out:pc_in;

 assign mux2 = (RegDst)?im_out[15:11]:im_out[20:16];

 assign mux3 = (AluSrc)?sign_out:rdB;

 assign mux4 = (MemToReg)?dout:out;


endmodule
