  // Define top-level testbench
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Top level has no inputs or outputs
// It only needs to instantiate CPU, Drive the inputs to CPU (clock, reset)
// and monitor the outputs. This is what all testbenches do

`timescale 1ns/1ps
`define clock_period 10

module cpu_tb;
parameter N = 32;

reg    clock, reset;    // Clock and reset signals
reg    [4:0] raA, raB, wa;
reg     wen;
reg    [3:0] op;
wire   [N-1:0] rdA, rdB;
wire   zero;
wire [N-1:0] ALUOut;
integer i;


// Instantiate ALU  module. Use connection-by-position
RegFile regs(clock, reset, raA, raB, wa, wen, ALUOut, rdA, rdB);

// Instantiate regfile module. Use connection-by-name
ALU  #(.N(32)) ALUInst (.out(ALUOut), .zero(zero), .inA(rdA), .inB(rdB), .op(op));

initial begin  // Ta statements apo ayto to begin mexri to "end" einai seiriaka

  // Initialize the module 
   clock = 1'b0;       
   reset = 1'b0;  // Apply reset for a few cycles
   #(4.25*`clock_period) reset = 1'b1;
   
  // Now apply some inputs  
   op = 4'b0010;   // ADD
   wen = 1;
   for (i = 0; i < 32; i = i+1)
     begin
#(1*`clock_period);
       raA = i; raB = 31-i; 
       wa = i;
     end
end 

// Generate clock by inverting the signal every half of clock period
always 
   #(`clock_period / 2) clock = ~clock;  
   
endmodule
