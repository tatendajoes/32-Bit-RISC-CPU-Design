`timescale 1ns / 1ps
module data_memory_tb;
  // Testbench signals
  reg         clk;
  reg         mem_read;
  reg         mem_write;
  reg  [31:0] addr;
  reg  [31:0] write_data;
  wire [31:0] read_data;
  integer     i;

  // Instantiate the Data Memory
  data_memory uut (
    .clk(clk),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .addr(addr),
    .write_data(write_data),
    .read_data(read_data)
  );

  // Clock generator: 10 ns period
  always #5 clk = ~clk;

  initial begin
    // Generate VCD file for waveform viewing
    $dumpfile("data_memory_tb.vcd");
    $dumpvars;
    
    // Initialize
    clk         = 0;
    mem_read    = 0;
    mem_write   = 0;
    addr        = 0;
    write_data  = 0;

    // Initial read (should be zero)
    mem_read = 1; addr = 32'h0000_0000; #1;
    $display("Initial read at addr=0x%0h: read_data=0x%0h (expect 0)", addr, read_data);
    mem_read = 0; #9;

    // Write pattern to four words
    for (i = 0; i < 4; i = i + 1) begin
      addr       = i * 4;
      write_data = {28'd0, i};             // small value i
      mem_write  = 1; #10;                 // write on rising edge
      mem_write  = 0; #10;
      $display("Wrote 0x%0h at addr=0x%0h", write_data, addr);
    end

    // Read back the written values
    mem_read = 1;
    for (i = 0; i < 4; i = i + 1) begin
      addr = i * 4; #1;
      $display("Read  at addr=0x%0h: read_data=0x%0h", addr, read_data);
      #9;
    end
    mem_read = 0;

    // Read with mem_read=0 (should output zero)
    addr = 32'h0000_0000; #1;
    $display("Read with mem_read=0 at addr=0x%0h: read_data=0x%0h (expect 0)", addr, read_data);

    // Wait a bit and finish
    #10;
    $display("Simulation complete at time %0t", $time);
    $finish;
  end
endmodule
