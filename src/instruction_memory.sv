`timescale 1ns / 1ps

module instruction_memory (
  input  wire [31:0] addr,        // PC address 
  output reg  [31:0] instruction  // 32-bit instruction
);
  
  // 256 × 32-bit instruction memory (1KB)
  reg [31:0] memory [0:255];
  
  initial begin
    // Initialize to NOPs
    integer i;
    for (i = 0; i < 256; i = i + 1) begin
      memory[i] = 32'h00000013;
    end
    
    // Load program from hex file if it exists
    // $readmemh("program.hex", memory);
  end
  
  // Combinational read - word-aligned addressing
  always @(*) begin
    instruction = memory[addr[9:2]];
  end
  
endmodule
