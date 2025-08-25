`timescale 1ns / 1ps

module program_counter
  (input wire clk,
   input wire rst,
   input  wire [31:0] next_pc, 
   output reg [31:0] pc
  );
  
  always @(posedge clk or negedge rst)
    begin
      if (~rst)
        pc <= 32'b0;
      else if (pc >= 32'd1020) // Memory overflow protection
        pc <= 32'b0;
      else
        pc <= next_pc;
    end
endmodule
