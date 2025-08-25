`timescale 1ns / 1ps

module alu_tb;
  // Inputs to the ALU
  reg [31:0] a;
  reg [31:0] b;
  reg [2:0]  alu_op;

  // Outputs from the ALU
  wire [31:0] result;
  wire        zero;

  // Instantiate the ALU
  alu uut (
    .a(a),
    .b(b),
    .alu_op(alu_op),
    .result(result),
    .zero(zero)
  );

  initial begin
    $display("time | op  |           a |           b |       result | zero");
    $display("---------------------------------------------------------------");

    // Test ADD: 5 + 7 = 12, zero=0
    a = 32'd5; b = 32'd7; alu_op = 3'b000; #10;
    $display("%0t | ADD | %12d | %12d | %12d |   %b", $time, a, b, result, zero);

    // Test SUB: 7 - 7 = 0, zero=1
    a = 32'd7; b = 32'd7; alu_op = 3'b001; #10;
    $display("%0t | SUB | %12d | %12d | %12d |   %b", $time, a, b, result, zero);

    // Test AND: 0xF0F0F0F0 & 0x0FF00FF0 = 0x00F000F0, zero=0
    a = 32'hF0F0_F0F0; b = 32'h0FF0_0FF0; alu_op = 3'b010; #10;
    $display("%0t | AND | 0x%08h | 0x%08h | 0x%08h |   %b", $time, a, b, result, zero);

    // Test OR:  0xF000F000 | 0x0000F00F = 0xF000F00F, zero=0
    a = 32'hF000_F000; b = 32'h0000_F00F; alu_op = 3'b011; #10;
    $display("%0t | OR  | 0x%08h | 0x%08h | 0x%08h |   %b", $time, a, b, result, zero);

    // Test SLT: 3 < 5 → 1, zero=0
    a = 32'd3; b = 32'd5; alu_op = 3'b100; #10;
    $display("%0t | SLT | %12d | %12d | %12d |   %b", $time, a, b, result, zero);

    // Test SLT: -1 < 1 → 1, zero=0 (signed)
    a = -32'd1; b = 32'd1; alu_op = 3'b100; #10;
    $display("%0t | SLT | %12d | %12d | %12d |   %b", $time, a, b, result, zero);

    // Test default: undefined op → result=0, zero=1
    a = 32'd10; b = 32'd20; alu_op = 3'b111; #10;
    $display("%0t | DEF | %12d | %12d | %12d |   %b", $time, a, b, result, zero);

    $finish;
  end
endmodule
