`timescale 1ns / 1ps

module alu (
  input wire [31:0] a,
  input wire [31:0] b, 
  input wire [2:0] alu_op,
  output reg [31:0] result,
  output wire zero
);
  
  // ALU operation codes
  localparam ALU_ADD = 3'b000;
  localparam ALU_SUB = 3'b001;
  localparam ALU_AND = 3'b010;
  localparam ALU_OR  = 3'b011;
  localparam ALU_SLT = 3'b100;
  
  // ALU combinational logic 
  always @ (*) begin
    case (alu_op)
      ALU_ADD: result = a + b;
      ALU_SUB: result = a - b;
      ALU_AND: result = a & b;
      ALU_OR:  result = a | b;
      ALU_SLT: result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
      default: result = 32'b0;
    endcase
  end
  
  // Zero flag output
  assign zero = (result == 32'b0);
endmodule
