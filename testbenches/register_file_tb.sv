`timescale 1ns / 1ps

module register_file_tb;
  // Testbench signals
  reg         clk;
  reg         we;
  reg  [4:0]  rd, rs1, rs2;
  reg  [31:0] wd;
  wire [31:0] rd1, rd2;
  integer     i;

  // Instantiate register file
  register_file uut (
    .clk(clk),
    .we(we),
    .rd(rd),
    .wd(wd),
    .rs1(rs1),
    .rs2(rs2),
    .rd1(rd1),
    .rd2(rd2)
  );

  // Clock generator: 10 ns period
  always #5 clk = ~clk;

  initial begin
    // Generate VCD file for waveform viewing
    $dumpfile("register_file_tb.vcd");
    $dumpvars;
    
    // Initialize
    clk   = 0;
    we    = 0;
    rd    = 0;
    rs1   = 0;
    rs2   = 0;
    wd    = 0;

    // Wait a couple cycles and check reset state (all zeros)
    #20;
    $display("Initial: rd1=0x%0h rd2=0x%0h (should both be 0)", rd1, rd2);

    // Write 0xDEADBEEF to x1
    we  = 1;
    rd  = 5'd1;
    wd  = 32'hDEADBEEF;
    rs1 = 5'd1;  rs2 = 5'd0;
    #10;         // on posedge clk
    we  = 0;
    #10;
    $display("After write x1: rd1=0x%0h (expect DEADBEEF), rd2=0x%0h (expect 0)", rd1, rd2);

    // Attempt write to x0 (should be ignored)
    we  = 1;
    rd  = 5'd0;
    wd  = 32'hCAFEBABE;
    rs1 = 5'd0;
    #10;
    we  = 0;
    #10;
    $display("After write x0: rd1=0x%0h (still 0)", rd1);

    // Write distinct values to x2 and x3 and read both
    for (i = 2; i <= 3; i = i + 1) begin
      we  = 1;
      rd  = i;
      wd  = {i[3:0], i[3:0], i[3:0], i[3:0]};
      rs1 = i;
      rs2 = (i==2) ? 5'd3 : 5'd2;
      #10;
      we  = 0;
      #10;
      $display("Write x%0d=0x%0h -> rd1=0x%0h rd2=0x%0h",
               i, wd, rd1, rd2);
    end

    // Wait a bit more and finish
    #10;
    $display("Simulation complete at time %0t", $time);
    $finish;
  end
endmodule
