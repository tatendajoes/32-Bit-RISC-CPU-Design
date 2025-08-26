`timescale 1ns / 1ps

module instruction_memory_tb;
  // signals
  reg  [31:0] pc;            // byte address input
  wire [31:0] instruction;   // instruction output
  integer i;                 // loop counter

  // instantiate DUT
  instruction_memory uut (
    .addr(pc),
    .instruction(instruction)
  );

  initial begin
    // VCD generation
    $dumpfile("instruction_memory_tb.vcd");
    $dumpvars;
    
    // preload the ROM
    uut.memory[0] = 32'hAA12B0C2;
    uut.memory[1] = 32'hAAC2B0C2;
    uut.memory[2] = 32'hAAD2B0C2;
    uut.memory[3] = 32'hA212B0C2;
    uut.memory[4] = 32'hA412B0C2;
    uut.memory[5] = 32'hA112B0C2;
    uut.memory[6] = 32'hA512B0C2;

    // step through seven instructions
    pc = 0;
    for (i = 0; i < 7; i = i + 1) begin
      #10;
      $display("%0t | pc=0x%0h | idx=0x%0h | instr=0x%0h",
               $time, pc, pc[9:2], instruction);
      pc = pc + 4;
    end

    $finish;
  end
endmodule
