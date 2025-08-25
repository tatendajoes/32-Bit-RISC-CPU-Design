`timescale 1ns / 1ps

module program_counter_tb;
  // Signal declarations
  reg clk;
  reg rst;
  reg [31:0] next_pc; 
  wire [31:0] pc;
  
  // Instantiate program counter
  program_counter uut ( 
    .clk(clk), 
    .rst(rst), 
    .next_pc(next_pc),
    .pc(pc)
  );
  
  // Clock generation - 10MHz
  always #50 clk = ~clk;
  
  // Test stimulus
  initial begin
    // VCD dump for waveform analysis
    $dumpfile("pc_simulation.vcd");
    $dumpvars(0);
    
    clk = 0;
    rst = 0;
    next_pc = 32'h00000000;
    
    $display("=== PC Testbench Starting ===");
    
    // Hold reset for 2 clock cycles
    #200;
    rst = 1;
    $display("Reset released at time %0t", $time);
    
    // Test sequential execution
    $display("--- Testing Sequential Execution ---");
    repeat(20) begin
      #100;
      next_pc = next_pc + 4;
    end
    
    // Test jump to address 0x100
    $display("--- Testing Jump to address 0x100 ---");
    next_pc = 32'h00000100;
    #300;
    
    // Continue sequential from new address
    repeat(10) begin
      #100;
      next_pc = next_pc + 4;
    end
    
    // Test jump to address 0x200
    $display("--- Testing Jump to address 0x200 ---");
    next_pc = 32'h00000200;
    #300;
    
    // Test backward jump (loop simulation)
    $display("--- Testing Loop (backward jump) ---");
    next_pc = 32'h00000180;
    #300;
    repeat(5) begin
      #100;
      next_pc = next_pc + 4;
    end
    
    // Test overflow protection
    $display("--- Testing Overflow Protection ---");
    next_pc = 32'd1016;
    #300;
    next_pc = 32'd1020;
    #300;
    next_pc = 32'd1024;
    #300;
    
    // Test reset during operation
    $display("--- Testing Reset During Operation ---");
    rst = 0;
    #200;
    rst = 1;
    next_pc = 32'h00000008;
    #500;
    
    $display("=== PC Testbench Complete ===");
    $finish;
  end
  
  // Monitor signal changes
  initial begin 
    $monitor("Time %0t | clk %b | rst %b | next_pc %0d | pc %0d", 
             $time, clk, rst, next_pc, pc);
  end
endmodule
