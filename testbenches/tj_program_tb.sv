`timescale 1ns / 1ps

module tj_program_tb;
    // Signals
    reg clk;
    reg rst_n;
    wire [31:0] pc, instr;
    wire mem_read, mem_write;
    wire [31:0] mem_addr, mem_wdata, mem_rdata;
    
    // CPU instance
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
    
    // Data Memory instance
    data_memory dm (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(mem_addr),
        .write_data(mem_wdata),
        .read_data(mem_rdata)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock
    end
    
    // Test sequence
    initial begin
        $display("=== Running TJ Language Program on RISC-V CPU ===");
        
        // Initialize
        rst_n = 0;
        #20;
        rst_n = 1;
        
        // Load program from hex file into instruction memory
        $readmemh("program.hex", uut.imem.memory);
        $display("Program loaded from program.hex");
        
        // Initialize some registers through register file for testing
        // Note: This is a hack for simulation - normally programs initialize their own data
        #10;
        force uut.rf.registers[2] = 32'h00000005;  // r2 = 5
        force uut.rf.registers[3] = 32'h00000003;  // r3 = 3
        #1;
        release uut.rf.registers[2];
        release uut.rf.registers[3];
        
        $display("Initial values set: r2 = 5, r3 = 3");
        
        // Run for enough cycles to execute the program
        repeat(20) begin
            @(posedge clk);
            $display("Cycle %2d: PC=%08h, Instr=%08h", 
                     $time/10-2, pc, instr);
            
            // Show memory operations
            if (mem_write) begin
                $display("  Memory write: addr=%08h, data=%08h", mem_addr, mem_wdata);
            end
            if (mem_read) begin
                $display("  Memory read:  addr=%08h, data=%08h", mem_addr, mem_rdata);
            end
        end
        
        $display("\n=== Final Register File State ===");
        // Display final register values
        $display("r0 = %08h (%0d) - Always 0", uut.rf.registers[0], uut.rf.registers[0]);
        $display("r1 = %08h (%0d) - Expected: r2+r3 = 5+3 = 8", uut.rf.registers[1], uut.rf.registers[1]);
        $display("r2 = %08h (%0d) - Initial value = 5", uut.rf.registers[2], uut.rf.registers[2]);
        $display("r3 = %08h (%0d) - Initial value = 3", uut.rf.registers[3], uut.rf.registers[3]);
        $display("r4 = %08h (%0d) - Expected: r1-r2 = 8-5 = 3", uut.rf.registers[4], uut.rf.registers[4]);
        $display("r5 = %08h (%0d) - Expected: r1&r2 = 8&5 = 0", uut.rf.registers[5], uut.rf.registers[5]);
        $display("r6 = %08h (%0d) - Expected: r1|r2 = 8|5 = 13", uut.rf.registers[6], uut.rf.registers[6]);
        $display("r7 = %08h (%0d) - Expected: r1<r2 = 8<5 = 0", uut.rf.registers[7], uut.rf.registers[7]);
        $display("r8 = %08h (%0d) - Expected: memory[0] = r1 = 8", uut.rf.registers[8], uut.rf.registers[8]);
        $display("r9 = %08h (%0d) - Expected: memory[4] = r4 = 3", uut.rf.registers[9], uut.rf.registers[9]);
        
        $display("\n=== Final Data Memory State ===");
        $display("memory[0] = %08h (%0d) - Should contain r1 = 8", dm.memory[0], dm.memory[0]);
        $display("memory[1] = %08h (%0d) - Should contain r4 = 3", dm.memory[1], dm.memory[1]);
        
        // Simple verification
        $display("\n=== Verification ===");
        if (uut.rf.registers[1] == 8) $display("✓ r1 = r2 + r3 = 8 (PASS)");
        else $display("✗ r1 = %d, expected 8 (FAIL)", uut.rf.registers[1]);
        
        if (uut.rf.registers[4] == 3) $display("✓ r4 = r1 - r2 = 3 (PASS)");
        else $display("✗ r4 = %d, expected 3 (FAIL)", uut.rf.registers[4]);
        
        if (uut.rf.registers[5] == 0) $display("✓ r5 = r1 & r2 = 0 (PASS)");
        else $display("✗ r5 = %d, expected 0 (FAIL)", uut.rf.registers[5]);
        
        if (uut.rf.registers[6] == 13) $display("✓ r6 = r1 | r2 = 13 (PASS)");
        else $display("✗ r6 = %d, expected 13 (FAIL)", uut.rf.registers[6]);
        
        $display("\n=== TJ Language → RISC-V CPU Pipeline Complete! ===");
        $finish;
    end
    
    // Generate VCD for waveform viewing
    initial begin
        $dumpfile("tj_program.vcd");
        $dumpvars(0, tj_program_tb);
    end
    
endmodule
