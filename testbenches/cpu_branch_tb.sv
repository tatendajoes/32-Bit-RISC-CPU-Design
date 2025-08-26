`timescale 1ns / 1ps

module cpu_branch_tb;
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
    $dumpfile("cpu_branch_tb.vcd");
    $dumpvars(0, cpu_branch_tb);
  end

  // Track PC changes for branch analysis
  reg [31:0] prev_pc;
  always @(posedge clk) begin
    if (rst_n) begin
      $display("Time %0t | PC: 0x%0h -> 0x%0h | instr=0x%0h", 
               $time, prev_pc, pc, instr);
      if (pc != prev_pc + 4 && prev_pc != 0)
        $display("*** BRANCH TAKEN: PC jumped from 0x%0h to 0x%0h ***", prev_pc, pc);
      prev_pc <= pc;
    end
  end

  initial begin
    $display("=== CPU Branch and Control Flow Test ===");
    clk = 0;
    rst_n = 0;
    prev_pc = 0;

    // Initialize data memory
    dm.mem[0] = 32'd10;  
    dm.mem[1] = 32'd10;  
    dm.mem[2] = 32'd5;

    // Program: Branch operations
    // Load test values
    uut.imem.memory[0] = 32'h00002083; // lw x1,0(x0)
    uut.imem.memory[1] = 32'h00402103; // lw x2,4(x0)
    uut.imem.memory[2] = 32'h00802183; // lw x3,8(x0)
    
    // Test branch equal
    uut.imem.memory[3] = 32'h00208463; // beq x1,x2,8
    uut.imem.memory[4] = 32'h002081B3; // add x3,x1,x2
    uut.imem.memory[5] = 32'h40208233; // sub x4,x1,x2
    uut.imem.memory[6] = 32'h0020F2B3; // and x5,x1,x2
    
    // Test branch not equal  
    uut.imem.memory[7] = 32'h00309463; // beq x1,x3,8
    uut.imem.memory[8] = 32'h0020E333; // or x6,x1,x2
    uut.imem.memory[9] = 32'h0020A3B3; // slt x7,x1,x2
    uut.imem.memory[10] = 32'h00112433; // slt x8,x2,x1
    
    // Store final results
    uut.imem.memory[11] = 32'h00302623; // sw x3,12(x0)
    uut.imem.memory[12] = 32'h00402823; // sw x4,16(x0)
    uut.imem.memory[13] = 32'h00502A23; // sw x5,20(x0)
    uut.imem.memory[14] = 32'h00602C23; // sw x6,24(x0)

    #10 rst_n = 1;
    $display("Reset released, testing branch operations...");

    // Run for 400ns
    #400;
    
    $display("=== Branch Test Results ===");
    $display("Register values:");
    $display("x1 = %0d (loaded 10)", uut.rf.regs[1]);
    $display("x2 = %0d (loaded 10)", uut.rf.regs[2]);
    $display("x3 = %0d (loaded 5)", uut.rf.regs[3]);
    $display("x4 = %0d (should be 0 - skipped by branch)", uut.rf.regs[4]);
    $display("x5 = %0d (should be 10 - branch target)", uut.rf.regs[5]);
    $display("x6 = %0d (should be 10 - no branch)", uut.rf.regs[6]);
    $display("x7 = %0d (should be 0 - no branch)", uut.rf.regs[7]);
    $display("x8 = %0d (should be 0 - fall through)", uut.rf.regs[8]);
    
    $display("Memory results:");
    $display("Memory[3] = %0d (x3 stored)", dm.mem[3]);
    $display("Memory[4] = %0d (x4 stored)", dm.mem[4]);
    $display("Memory[5] = %0d (x5 stored)", dm.mem[5]);
    $display("Memory[6] = %0d (x6 stored)", dm.mem[6]);
    
    $finish;
  end
endmodule
