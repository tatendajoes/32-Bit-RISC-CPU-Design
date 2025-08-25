`timescale 1ns / 1ps

module register_file (
  input  wire        clk,
  input  wire        we,
  input  wire [4:0]  rd,
  input  wire [31:0] wd,
  input  wire [4:0]  rs1,
  input  wire [4:0]  rs2,
  output wire [31:0] rd1,
  output wire [31:0] rd2
);

  // 32 × 32-bit register array
  reg [31:0] regs [0:31];
  integer i;

  // Initialize all registers to zero at time 0
  initial begin
    for (i = 0; i < 32; i = i + 1) begin
      regs[i] = 32'b0;
    end
  end

  // Synchronous write on rising clock edge
  always @(posedge clk) begin
    if (we && rd != 5'd0) begin
      regs[rd] <= wd;
    end
  end

  // Asynchronous reads; x0 is always zero
  assign rd1 = (rs1 == 5'd0) ? 32'b0 : regs[rs1];
  assign rd2 = (rs2 == 5'd0) ? 32'b0 : regs[rs2];

endmodule
