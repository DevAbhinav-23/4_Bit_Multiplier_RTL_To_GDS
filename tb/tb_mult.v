`timescale 1ns/1ps
// Exhaustive self-checking testbench for mult_array (all 256 vectors)
module tb_mult;
    reg        clk   = 1'b0;
    reg        rst_n = 1'b0;
    reg  [3:0] a     = 4'd0;
    reg  [3:0] b     = 4'd0;
    wire [7:0] p;

    integer i, j;
    integer vectors = 0;
    integer errors  = 0;

    mult_array dut (
        .clk  (clk),
        .rst_n(rst_n),
        .a    (a),
        .b    (b),
        .p    (p)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    initial begin
        $dumpfile("mult.vcd");
        $dumpvars(0, tb_mult);

        // hold reset low for the first 2 clock cycles
        repeat (2) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;

        // inputs change on the falling edge, so they are stable at each rising edge
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i;
                b = j;
                @(posedge clk);   // edge 1: a, b captured into input registers
                @(posedge clk);   // edge 2: product captured into p
                @(negedge clk);   // check half a cycle later, when p is stable
                vectors = vectors + 1;
                if (p !== i * j) begin
                    errors = errors + 1;
                    $display("MISMATCH: a=%0d b=%0d p=%0d expected=%0d (t=%0t)",
                             i, j, p, i * j, $time);
                end
            end
        end

        if (errors == 0)
            $display("PASS: %0d vectors checked, 0 errors", vectors);
        else
            $display("FAIL: %0d vectors checked, %0d errors", vectors, errors);
        $finish;
    end
endmodule
