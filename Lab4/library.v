
// This file contains library modules to be used in your design. 

//`include "constants.h"
`timescale 1ns/1ps

module PC(reset,clock,pc_in, pc_out);
input reset,clock;
input [31:0]  pc_in;
output [31:0] pc_out;

reg [31:0] pc_out;


always @(negedge clock or reset)
begin
if (reset == 1'b1)
   pc_out <= pc_in;
else 
   pc_out = 32'h0;
end
   endmodule 

module add(in_add,out_add);
input [31:0]in_add ;
output [31:0] out_add ; 

assign out_add = in_add + 1 ;
endmodule   

//Instruction memory
module Instruction_mem (im_ra, im_out);
 input [31:0] im_ra;
 output [31:0] im_out;

 reg [31:0] data [31:0];


 assign im_out = data[im_ra];

endmodule


// Small ALU. 
//     Inputs: inA, inB, op. 
//     Output: out, zero
// Operations: bitwise and (op = 0)
//             bitwise or  (op = 1)
//             addition (op = 2)
//             subtraction (op = 6)
//             slt  (op = 7)
//             nor (op = 12)
module ALU (out, zero, inA, inB, op);

  output [31:0] out;
  output zero;
  input  [31:0] inA, inB;
  input    [3:0] op;

  assign out = 
			(op == 4'b0000) ? inA & inB :
			(op == 4'b0001) ? inA | inB :
			(op == 4'b0010) ? inA + inB : 
			(op == 4'b0110) ? inA - inB : 
			(op == 4'b0111) ? ((inA < inB)?1:0) : 
			(op == 4'b1100) ? ~(inA | inB) :
			'bx;

  assign zero = (out == 0);
endmodule






// Memory (active 1024 words, from 10 address ).
// Read : enable ren, address addr, data dout
// Write: enable wen, address addr, data din.
module Memory (ren, wen, addr, din, dout);
  input         ren, wen;
  input  [31:0] addr, din;
  output [31:0] dout;

  reg [31:0] data[4095:0];
  wire [31:0] dout;

  always @(ren or wen)   // It does not correspond to hardware. Just for error detection
    if (ren & wen)
      $display ("\nMemory ERROR (time %0d): ren and wen both active!\n", $time);

  always @(posedge ren or posedge wen) begin // It does not correspond to hardware. Just for error detection
    if (addr[31:10] != 0)
      $display("Memory WARNING (time %0d): address msbs are not zero\n", $time);
  end  

  assign dout = ((wen==1'b0) && (ren==1'b1)) ? data[addr[9:0]] : 32'bx;  
  
  always @(din or wen or ren or addr)
   begin
    if ((wen == 1'b1) && (ren==1'b0))
        data[addr[9:0]] <= din;
   end

endmodule




// Register File. Input ports: address raA, data rdA
//                            address raB, data rdB
//                Write port: address wa, data wd, enable wen.

module RegFile (clock, reset, raA, raB, wa, wen, wd, rdA, rdB);

  input  clock, reset;
  input   [4:0] raA, raB, wa;
  input         wen;
  input  [31:0] wd;
  output [31:0] rdA, rdB;
  integer i;
  
  reg [31:0] data[31:0];
  
  assign rdA =  data[raA];
  assign rdB = data[raB];

  
  // Make sure  that register file is only written at the negative edge of the clock 
  always @(negedge clock or reset)
   begin
    if (reset == 1'b0)
        for (i = 0; i < 32; i = i+1)
           data[i] <= i; 
    else if (wen == 1'b1 && wa != 5'b0)  // In MIPS, R0 should always remain 0
           data[wa] <=  wd;
   end

endmodule





// Module to control the data path. 
//                          Input: op, func of the inpstruction
//                          Output: all the control signals needed 


module Control(opcode,RegWrite,RegDst,MemRead,AluSrc,Branch,MemWrite,MemToReg,ALUop);

 

  input [5:0] opcode; 
 
  output RegWrite,RegDst,AluSrc,Branch,MemWrite,MemToReg,MemRead;
  output [1:0] ALUop;

  reg RegWrite ,MemWrite ,Branch ,RegDst ,MemToReg, AluSrc,MemRead;
  reg [1:0] ALUop;
  
  
 always@(*) begin
  if(opcode == 6'b000000) //R-Type
    begin
     RegWrite = 1'b1;
     RegDst = 1'b1;
     AluSrc = 1'b0;
     Branch = 1'b0;
     MemWrite = 1'b0;
     MemToReg = 1'b0;
     ALUop = 2'b10;
     MemRead =1'b0;
   end
   
   else if (opcode == 6'b100011) //lw
    begin
     RegWrite = 1'b1;
     RegDst = 1'b0;
     AluSrc = 1'b1;
     Branch = 1'b0;
     MemWrite = 1'b0;
     MemToReg = 1'b1;
     ALUop = 2'b00;
     MemRead = 1'b1;
    end
    
   else if (opcode == 6'b101011) //sw
    begin
     RegWrite = 1'b0;
     RegDst = 1'bx;
     AluSrc = 1'b1;
     Branch = 1'b0;
     MemWrite = 1'b1;
     MemToReg = 1'bx;
     ALUop = 2'b00;
     MemRead =1'b0;
    end
   
   else if (opcode == 6'b000100) //beq
   begin
    RegWrite = 1'b0;
    RegDst = 1'bx;
    AluSrc = 1'b0;
    Branch = 1'b1;
    MemWrite = 1'b0;
    MemToReg = 1'bx;
    ALUop = 2'b01;
    MemRead =1'b0;
   end
  
  else if (opcode == 6'b001000) //addi
   begin
    RegWrite = 1'b1;
    RegDst = 1'b0;
    AluSrc = 1'b1;
    Branch = 1'b0;
    MemWrite = 1'b0;
    MemToReg = 1'b0;
    ALUop = 2'b00;
    MemRead =1'b0;
   end
 end//always
  //else if (opcode == 6'b000010) // j
  
endmodule //endofcontrol


module ALUControl(aluop,func,ALUcontrol);
    
  input [5:0] func;
  input [1:0] aluop;
  output [3:0] ALUcontrol;
  reg [3:0] ALUcontrol; 
  
  always@(*) begin
 if(aluop == 2'b10) 
 begin
   
  ALUcontrol =
  		(func == 6'b100000) ? 4'b0010:
		(func == 6'b100010) ? 4'b0110:
		(func == 6'b100100) ? 4'b0000: 
		(func == 6'b100101) ? 4'b0001: 
		(func == 6'b101010) ? 4'b0111:
		 'bx;
	end else if (aluop == 2'b00)begin 
		ALUcontrol = 4'b0010;
			
	end else if (aluop == 2'b01)begin 
		ALUcontrol = 4'b0110;
			
	end 

  
end 
  
endmodule //endofalucontrol

module sign_extend(sign_in,sign_out);
  
input [15:0] sign_in;
output [31:0] sign_out;
reg [31:0] sign_out;
always@(*)begin 
if (sign_in[15] == 1'b1) begin 
  
  sign_out = {16'hffff,sign_in};
end 
else sign_out = {16'h0000,sign_in};
  
end 

 
endmodule 
  






 
   
  

