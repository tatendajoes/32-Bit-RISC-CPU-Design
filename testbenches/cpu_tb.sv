`timescale 1ns / 1ps

module cpu_tb;
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
    $dumpfile("cpu_basic_tb.vcd");
    $dumpvars(0, cpu_tb);
  end

  // Debug output
  always @(posedge clk) begin
    if (rst_n)
      $display("Time %0t | PC=0x%0h | instr=0x%0h", $time, pc, instr);
    if (mem_write)
      $display("STORE @%0h = %0d", mem_addr, mem_wdata);
  end

  initial begin
    $display("=== CPU Basic Functionality Test ===");
    clk = 0;
    rst_n = 0;

    // Preload data memory
    dm.mem[0] = 32'd10;  
    dm.mem[1] = 32'd20;  
    dm.mem[2] = 32'd30;

    // Load instruction memory with basic program
    uut.imem.memory[0] = 32'h00002083; // lw x1,0(x0)
    uut.imem.memory[1] = 32'h00402103; // lw x2,4(x0)
    uut.imem.memory[2] = 32'h002081B3; // add x3,x1,x2
    uut.imem.memory[3] = 32'h00302223; // sw x3,4(x0)

    #10 rst_n = 1;
    $display("Reset released, starting execution...");

    // Run for 200ns
    #200;
    
    $display("=== Final Memory State ===");
    $display("Memory[0] = %0d", dm.mem[0]);
    $display("Memory[1] = %0d", dm.mem[1]);
    $display("Memory[2] = %0d", dm.mem[2]);
    
    $finish;
  end
endmodule
