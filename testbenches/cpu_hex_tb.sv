`timescale 1ns / 1ps

module cpu_hex_tb;
  reg clk;
  reg rst_n;
  wire [31:0] pc, instr;
  wire mem_read, mem_write;
  wire [31:0] mem_addr, mem_wdata, mem_rdata;

  // Instantiate CPU
  cpu uut (
    .clk(clk),
    .rst_n(rst_n),
    .pc(pc),
    .instr(instr),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .mem_rdata(mem_rdata)
  );

  // Instantiate Data Memory
  data_memory dm (
    .clk(clk),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .addr(mem_addr),
    .write_data(mem_wdata),
    .read_data(mem_rdata)
  );

  // Clock generator
  always #5 clk = ~clk;

  // VCD generation
  initial begin
    $dumpfile("cpu_hex_tb.vcd");
    $dumpvars(0, cpu_hex_tb);
  end

  // Monitor execution
  always @(posedge clk) begin
    if (rst_n) begin
      $display("Time %0t | PC=0x%0h | instr=0x%0h", $time, pc, instr);
      if (mem_write)
        $display("  STORE: mem[%0h] = %0d", mem_addr, mem_wdata);
    end
  end

  initial begin
    $display("=== CPU Hex File Test ===");
    clk = 0;
    rst_n = 0;

    // Initialize data memory
    dm.mem[0] = 32'd15;  // Test data
    dm.mem[1] = 32'd25;  
    dm.mem[2] = 32'd0;
    dm.mem[3] = 32'd0;

    // Load program from hex file
    $display("Loading program from hex file...");
    $readmemh("program.hex", uut.imem.memory);
    
    // Initialize data memory with test values for TJ program
    dm.memory[0] = 32'd5;  // Test value for r2
    dm.memory[1] = 32'd3;  // Test value for r3 (memory[4] = word address 1)
    $display("Initialized data memory: mem[0] = 5, mem[1] = 3");
    
    // Display loaded program
    $display("Loaded Instructions:");
    for (integer i = 0; i < 16; i++) begin
      $display("  [%2d] 0x%08h", i, uut.imem.memory[i]);
    end

    #10 rst_n = 1;
    $display("Reset released, starting execution...");

    // Run for 300ns
    #300;
    
    $display("=== Execution Results ===");
    $display("Register File:");
    for (integer i = 1; i < 9; i++) begin
      $display("  x%0d = %0d", i, uut.rf.regs[i]);
    end
    
    $display("Data Memory:");
    for (integer i = 0; i < 8; i++) begin
      $display("  mem[%0d] = %0d", i, dm.mem[i]);
    end
    
    $display("Final PC: 0x%0h", pc);
    $finish;
  end
endmodule
