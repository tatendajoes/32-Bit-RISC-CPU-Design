`timescale 1ns / 1ps

module control_unit_tb;
  // Inputs
  reg [6:0] opcode;
  reg [2:0] funct3;
  reg       funct7_5;
  // Outputs
  wire      reg_write;
  wire      alu_src;
  wire      mem_read;
  wire      mem_write;
  wire      mem_to_reg;
  wire      branch;
  wire [2:0] alu_op;

  // Instantiate the Control Unit
  control_unit uut (
    .opcode(opcode),
    .funct3(funct3),
    .funct7_5(funct7_5),
    .reg_write(reg_write),
    .alu_src(alu_src),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .branch(branch),
    .alu_op(alu_op)
  );

  initial begin
    // VCD generation
    $dumpfile("control_unit_tb.vcd");
    $dumpvars;
    
    $display("\nTime | opcode  funct3 funct7_5 | reg_wr alu_src mem_rd mem_wr mem2reg branch alu_op");
    $display("-------------------------------------------------------------------------------");

    // R-type: ADD
    opcode = 7'b0110011; funct3 = 3'b000; funct7_5 = 1'b0; #10;
    $display("ADD  | %b %b      %b   |   %b      %b      %b      %b      %b      %b     %b", opcode, funct3, funct7_5, reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, alu_op);

    // R-type: SUB
    opcode = 7'b0110011; funct3 = 3'b000; funct7_5 = 1'b1; #10;
    $display("SUB  | %b %b      %b   |   %b      %b      %b      %b      %b      %b     %b", opcode, funct3, funct7_5, reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, alu_op);

    // R-type: AND
    opcode = 7'b0110011; funct3 = 3'b111; funct7_5 = 1'b0; #10;
    $display("AND  | %b %b      %b   |   %b      %b      %b      %b      %b      %b     %b", opcode, funct3, funct7_5, reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, alu_op);

    // R-type: OR
    opcode = 7'b0110011; funct3 = 3'b110; funct7_5 = 1'b0; #10;
    $display("OR   | %b %b      %b   |   %b      %b      %b      %b      %b      %b     %b", opcode, funct3, funct7_5, reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, alu_op);

    // R-type: SLT
    opcode = 7'b0110011; funct3 = 3'b010; funct7_5 = 1'b0; #10;
    $display("SLT  | %b %b      %b   |   %b      %b      %b      %b      %b      %b     %b", opcode, funct3, funct7_5, reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, alu_op);

    // Load Word
    opcode = 7'b0000011; funct3 = 3'b010; funct7_5 = 1'b0; #10;
    $display("LW   | %b %b      %b   |   %b      %b      %b      %b      %b      %b     %b", opcode, funct3, funct7_5, reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, alu_op);

    // Store Word
    opcode = 7'b0100011; funct3 = 3'b010; funct7_5 = 1'b0; #10;
    $display("SW   | %b %b      %b   |   %b      %b      %b      %b      %b      %b     %b", opcode, funct3, funct7_5, reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, alu_op);

    // Branch if Equal
    opcode = 7'b1100011; funct3 = 3'b000; funct7_5 = 1'b0; #10;
    $display("BEQ  | %b %b      %b   |   %b      %b      %b      %b      %b      %b     %b", opcode, funct3, funct7_5, reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, alu_op);

    // Default (undefined opcode)
    opcode = 7'b1111111; funct3 = 3'bxxx; funct7_5 = 1'bx; #10;
    $display("DEF  | %b %b      %b   |   %b      %b      %b      %b      %b      %b     %b", opcode, funct3, funct7_5, reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, alu_op);

    $finish;
  end
endmodule
