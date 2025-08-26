`timescale 1ns / 1ps
// Pull in each module's source
`include "pc.sv"
`include "instruction_memory.sv"
`include "register_file.sv"
`include "alu.sv"
`include "control_unit.sv"
`include "data_memory.sv"

// Top‐level single‐cycle CPU
module cpu (
  input  wire        clk,
  input  wire        rst_n,       // active‐low reset
  output wire [31:0] pc,          // program counter
  output wire [31:0] instr,       // fetched instruction
  output wire        mem_read,
  output wire        mem_write,
  output wire [31:0] mem_addr,
  output wire [31:0] mem_wdata,
  input  wire [31:0] mem_rdata
);

  // 1) PC instance
  wire [31:0] next_pc;
  program_counter pc_inst (
    .clk     (clk),
    .rst     (rst_n),
    .next_pc (next_pc),
    .pc      (pc)
  );
  wire [31:0] pc_plus4 = pc + 32'd4;

  // 2) Fetch instruction
  instruction_memory imem (
    .addr        (pc),
    .instruction (instr)
  );

  // 3) Decode & control
  wire        reg_write, alu_src, mem_to_reg, branch;
  wire [2:0]  alu_op;
  control_unit cu (
    .opcode     (instr[6:0]),
    .funct3     (instr[14:12]),
    .funct7_5   (instr[30]),
    .reg_write  (reg_write),
    .alu_src    (alu_src),
    .mem_read   (mem_read),
    .mem_write  (mem_write),
    .mem_to_reg (mem_to_reg),
    .branch     (branch),
    .alu_op     (alu_op)
  );

  // 4) Register file & ALU result declaration
  wire [31:0] rs1_data, rs2_data;
  wire [31:0] alu_result;
  wire        zero_flag;

  register_file rf (
    .clk   (clk),
    .we    (reg_write),
    .rd    (instr[11:7]),
    .wd    (mem_to_reg ? mem_rdata : alu_result),
    .rs1   (instr[19:15]),
    .rs2   (instr[24:20]),
    .rd1   (rs1_data),
    .rd2   (rs2_data)
  );

  // 5) ALU operand multiplexing & ALU
  wire [31:0] imm_i = {{20{instr[31]}}, instr[31:20]};
  wire [31:0] imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
  wire [31:0] imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
  wire [31:0] imm   = (instr[6:0] == 7'b0000011) ? imm_i :
                      (instr[6:0] == 7'b0100011) ? imm_s :
                      (instr[6:0] == 7'b1100011) ? imm_b : 32'd0;
  wire [31:0] alu_in2 = alu_src ? imm : rs2_data;

  alu arithmetic_unit (
    .a      (rs1_data),
    .b      (alu_in2),
    .alu_op (alu_op),
    .result (alu_result),
    .zero   (zero_flag)
  );

  // 6) Data memory interface
  assign mem_addr  = alu_result;
  assign mem_wdata = rs2_data;

  // 7) Next PC logic
  wire [31:0] branch_target = pc + imm;
  assign next_pc = (branch && zero_flag) ? branch_target : pc_plus4;

endmodule
