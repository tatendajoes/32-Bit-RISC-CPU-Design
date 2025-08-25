`timescale 1ns / 1ps

// Single-cycle data memory for word-addressable loads and stores
module data_memory (
  input  wire        clk,        // clock for synchronous writes
  input  wire        mem_read,   // high to enable read
  input  wire        mem_write,  // high to enable write
  input  wire [31:0] addr,       // byte address
  input  wire [31:0] write_data, // data to write on store
  output wire [31:0] read_data   // data output on load
);

  // 256 × 32-bit memory array (1 KB)
  reg [31:0] mem [0:255];
  integer i;

  // Initialize memory to zero (optional)
  initial begin
    for (i = 0; i < 256; i = i + 1)
      mem[i] = 32'b0;
  end

  // Synchronous write
  always @(posedge clk) begin
    if (mem_write)
      mem[ addr[9:2] ] <= write_data;
  end

  // Asynchronous read (combinational)
  assign read_data = (mem_read) ? mem[ addr[9:2] ] : 32'b0;

endmodule
