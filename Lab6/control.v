`include "constants.h"

/************** Main control in ID pipe stage  *************/
module control_main(
				
				output reg RegDst,
                output reg Branch,  
                output reg MemRead,
                output reg MemWrite,  
                output reg MemToReg,  
                output reg ALUSrc,  
                output reg RegWrite,  	
                output reg [1:0] ALUcntrl,  
				output reg Jump_sign,
                input [5:0] opcode);
				
				
	

  always @(*) 
   begin
     case (opcode)
      `R_FORMAT: 
          begin 
            RegDst = 1'b1;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b1;
            Branch = 1'b0;         
            ALUcntrl  = 2'b10; // R    
			Jump_sign = 1'b0;			
          end
       `LW :   
           begin 
            RegDst = 1'b0;
            MemRead = 1'b1;
            MemWrite = 1'b0;
            MemToReg = 1'b1;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
            Branch = 1'b0;
            ALUcntrl  = 2'b00; // add
			Jump_sign = 1'b0;
           end
        `SW :   
           begin 
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b1;
            MemToReg = 1'b0;
            ALUSrc = 1'b1;
            RegWrite = 1'b0;
            Branch = 1'b0;
            ALUcntrl  = 2'b00; // add
			Jump_sign = 1'b0;
           end
       `BEQ  : 
           begin 
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b0;
            Branch = 1'b1;
            ALUcntrl = 2'b01; // sub
			Jump_sign = 1'b0;
           end
		   
	  `BNE  : 
           begin 
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b0;
            Branch = 1'b1;
            ALUcntrl = 2'b01; // sub
			Jump_sign = 1'b0;
           end
		   
	 `ADDI:
		   begin 
			RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b1;
            RegWrite = 1'b1;
            Branch = 1'b0;
            ALUcntrl = 2'b00; // add
			Jump_sign = 1'b0;
		end
		`J:
		 begin
			RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b0;
            Branch = 1'b0;
            ALUcntrl = 2'b00; // add
			Jump_sign = 1'b1;
		 end
       default:
           begin
            RegDst = 1'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemToReg = 1'b0;
            ALUSrc = 1'b0;
            RegWrite = 1'b0;
            ALUcntrl = 2'b00; 
			Jump_sign = 1'b0;
         end
      endcase
    end // always
endmodule




/**************** Module in EX pipe stage for PCSrc **************/
module PCsrc(input clock ,
			input reset ,
			input [5:0] opcode,
			input zero,
			input branch,
			output reg  PCSrc);
		
always@(*)	
begin	
		if(reset == 0)
			PCSrc = 0 ;
		else if(opcode == `BEQ)
			PCSrc = zero && branch;
		else if (opcode == `BNE)
			PCSrc = ~zero && branch;
		
end
endmodule


/**************** Module for Bypass Detection in EX pipe stage goes here  *********/
 module  control_bypass_ex(output reg [1:0] bypassA,
                       output reg [1:0] bypassB,
                       input [4:0] idex_rs,
                       input [4:0] idex_rt,
                       input [4:0] exmem_rd,
                       input [4:0] memwb_rd,
                       input       exmem_regwrite,
                       input       memwb_regwrite);

      /* Fill in module details */
	  
	  always@(*) begin
	  
	  /*************forwardA***********/
	  if( ((memwb_regwrite == 1'b1) && (memwb_rd != 4'b0000) && ( memwb_rd == idex_rs))  && ((exmem_rd != idex_rs) || (exmem_regwrite == 0)))
			bypassA = 2'b01;
	  else if ( (exmem_regwrite == 1'b1) && (exmem_rd != 4'b0000) && (exmem_rd == idex_rs))
			bypassA = 2'b10;
	  else
			bypassA = 2'b00;
	 /*************forwardB***********/
	 
	 if( ((memwb_regwrite == 2'b01) && (memwb_rd != 2'b00) && ( memwb_rd == idex_rt) ) && ((exmem_rd != idex_rt) || (exmem_regwrite == 0)))
			bypassB = 2'b01;
	 else if ( (exmem_regwrite == 2'b01) && (exmem_rd != 2'b00) && (exmem_rd == idex_rt))
			bypassB = 2'b10;
	 else
			bypassB = 2'b00;
	  
	  end
	  
endmodule          
                       

/**************** Module for Stall Detection in ID pipe stage goes here  *********/
  
module stall( output reg pc_write,
			output  reg ifid_write,
			 input PCSrc,
			 input [4:0] ifid_rs,
			 input [4:0] ifid_rt,
			 input idex_memread,
			 input [4:0] idex_register_rt,
			 output reg bubble_idex,
			 output reg  bubble_exmem,
			 output reg  bubble_ifid,
			 input Jump_sign);
			 
		 always@(*) begin
			  
			 if( (idex_memread == 2'b01) && (idex_register_rt == ifid_rs || idex_register_rt == ifid_rt) )
			  begin
				pc_write = 0;
				ifid_write = 0;
				bubble_ifid = 0;
				bubble_idex = 1;
				bubble_exmem = 0;
			  end
			 else if (PCSrc == 1) 
			  begin
			    pc_write = 1;
			    ifid_write = 0;
				bubble_ifid = 1;
				bubble_idex = 1;
				bubble_exmem = 1;
			  end
			 else if (Jump_sign  == 1)
			  begin 
			  pc_write = 1;
			  ifid_write = 0;
			  bubble_ifid = 1;
			  bubble_idex = 0;
			  bubble_exmem = 0;
			  
			  end 
			 else 
			  begin
				pc_write = 1;
				ifid_write =1;
				bubble_exmem =0;
				bubble_idex =0;	
				bubble_ifid =0;
				end 
		end
endmodule		 
		   
		   
		   
		   
		   
		   
                       
/************** control for ALU control in EX pipe stage  *************/
module control_alu(output reg [3:0] ALUOp,                  
               input [1:0] ALUcntrl,
               input [5:0] func);

  always @(ALUcntrl or func)  
    begin
      case (ALUcntrl)
        2'b10: 
           begin
             case (func)
              6'b100000: ALUOp = 4'b0010; // add
              6'b100010: ALUOp = 4'b0110; // sub
              6'b100100: ALUOp = 4'b0000; // and
              6'b100101: ALUOp = 4'b0001; // or
              6'b100111: ALUOp = 4'b1100; // nor
              6'b101010: ALUOp = 4'b0111; // slt
			  6'b001000: ALUOp = 4'b0010; // addi
			  6'b000000: ALUOp = 4'b1000; // sll 
			  6'b000100: ALUOp = 4'b0100; // sllv
			  6'b100110: ALUOp = 4'b1111; // xor
              default: ALUOp = 4'b0000;       
             endcase 
          end   
        2'b00: 
              ALUOp  = 4'b0010; // add
        2'b01: 
              ALUOp = 4'b0110; // sub
        default:
              ALUOp = 4'b0000;
     endcase
    end
endmodule
