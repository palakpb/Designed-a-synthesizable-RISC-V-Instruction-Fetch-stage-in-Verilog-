`timescale 1ns / 1ps
module riscv_tb;

    reg clk;
    reg reset;

    riscv_top DUT (
        .clk(clk),
        .reset(reset)
    );

    // CLOCK (STARTS AFTER RESET IS STABLE)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // RESET (CLEAN)
    initial begin
        reset = 1;
        #20;
        reset = 0;
        #200;
        $stop;
    end

endmodule


