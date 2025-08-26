`timescale 1ns / 1ps

// Single-cycle control unit
module control_unit (
  input wire [6:0] opcode,    // instruction opcode
  input wire [2:0] funct3,    // funct3 field
  input wire       funct7_5,  // top bit of funct7
  output reg       reg_write, // register file write enable
  output reg       alu_src,   // 0 = ALU second input from reg, 1 = immediate
  output reg       mem_read,  // data memory read enable
  output reg       mem_write, // data memory write enable
  output reg       mem_to_reg,// write-back source: 0 = ALU, 1 = memory
  output reg       branch,    // branch flag
  output reg [2:0] alu_op     // ALU operation code
);
  
  // ALU opcodes
  localparam ALU_ADD = 3'b000;
  localparam ALU_SUB = 3'b001;
  localparam ALU_AND = 3'b010;
  localparam ALU_OR  = 3'b011;
  localparam ALU_SLT = 3'b100;
  
  // RISC-V opcodes
  localparam OPC_RTYPE = 7'b0110011;  // R-type
  localparam OPC_LW    = 7'b0000011;  // Load word
  localparam OPC_SW    = 7'b0100011;  // Store word
  localparam OPC_BEQ   = 7'b1100011;  // Branch equal
  
  always @(*) begin
    // Default all signals to 0
    reg_write = 1'b0;
    alu_src = 1'b0;
    mem_read = 1'b0;
    mem_write = 1'b0;
    mem_to_reg = 1'b0;
    branch = 1'b0;
    alu_op = ALU_ADD;
    
    case(opcode)
      // R-type (ADD, SUB, AND, OR, SLT)
      OPC_RTYPE: begin
        reg_write = 1'b1;
        alu_src = 1'b0;      // use register data
        mem_to_reg = 1'b0;   // write ALU result to register
        case ({funct3, funct7_5})
          4'b0000: alu_op = ALU_ADD;  // ADD
          4'b0001: alu_op = ALU_SUB;  // SUB
          4'b1110: alu_op = ALU_AND;  // AND
          4'b1100: alu_op = ALU_OR;   // OR
          4'b0100: alu_op = ALU_SLT;  // SLT
          default: alu_op = ALU_ADD;
        endcase
      end
      
      // Load word
      OPC_LW: begin
        reg_write = 1'b1;    // write to register
        alu_src = 1'b1;      // use immediate for address calc
        mem_read = 1'b1;     // read from memory
        mem_to_reg = 1'b1;   // write memory data to register
        alu_op = ALU_ADD;    // address = base + offset
      end
      
      // Store word
      OPC_SW: begin
        alu_src = 1'b1;      // use immediate for address calc
        mem_write = 1'b1;    // write to memory
        alu_op = ALU_ADD;    // address = base + offset
      end
      
      // Branch equal
      OPC_BEQ: begin
        branch = 1'b1;       // enable branch logic
        alu_op = ALU_SUB;    // subtract to check equality
      end
      
      default: begin
        // Keep defaults (NOP behavior)
      end
    endcase
  end
endmodule
