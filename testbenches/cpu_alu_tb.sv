`timescale 1ns / 1ps

module cpu_alu_tb;
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
    $dumpfile("cpu_alu_tb.vcd");
    $dumpvars(0, cpu_alu_tb);
  end

  // Monitor register file contents
  always @(posedge clk) begin
    if (rst_n && uut.rf.we) begin
      $display("Time %0t | Register x%0d = %0d", $time, uut.rf.rd, uut.rf.wd);
    end
  end

  initial begin
    $display("=== CPU ALU Operations Test ===");
    clk = 0;
    rst_n = 0;

    // Initialize data memory
    dm.mem[0] = 32'd15;  
    dm.mem[1] = 32'd7;   
    dm.mem[2] = 32'd0;

    // Program: ALU operations
    // Load initial values
    uut.imem.memory[0] = 32'h00002083; // lw x1,0(x0)
    uut.imem.memory[1] = 32'h00402103; // lw x2,4(x0)
    
    // Arithmetic operations
    uut.imem.memory[2] = 32'h002081B3; // add x3,x1,x2
    uut.imem.memory[3] = 32'h40208233; // sub x4,x1,x2
    
    // Logical operations  
    uut.imem.memory[4] = 32'h0020F2B3; // and x5,x1,x2
    uut.imem.memory[5] = 32'h0020E333; // or x6,x1,x2
    
    // Set less than
    uut.imem.memory[6] = 32'h0020A3B3; // slt x7,x1,x2
    uut.imem.memory[7] = 32'h00112433; // slt x8,x2,x1
    
    // Store results
    uut.imem.memory[8] = 32'h00302423; // sw x3,8(x0)
    uut.imem.memory[9] = 32'h00402623; // sw x4,12(x0)

    #10 rst_n = 1;
    $display("Reset released, testing ALU operations...");

    // Run for 300ns
    #300;
    
    $display("=== ALU Test Results ===");
    $display("x1 (15): loaded from memory");
    $display("x2 (7):  loaded from memory");
    $display("x3 (22): 15 + 7 = %0d", uut.rf.regs[3]);
    $display("x4 (8):  15 - 7 = %0d", uut.rf.regs[4]);
    $display("x5 (7):  15 & 7 = %0d", uut.rf.regs[5]);
    $display("x6 (15): 15 | 7 = %0d", uut.rf.regs[6]);
    $display("x7 (0):  15 < 7 = %0d", uut.rf.regs[7]);
    $display("x8 (1):  7 < 15 = %0d", uut.rf.regs[8]);
    
    $display("Memory results:");
    $display("Memory[2] = %0d (should be 22)", dm.mem[2]);
    $display("Memory[3] = %0d (should be 8)", dm.mem[3]);
    
    $finish;
  end
endmodule
