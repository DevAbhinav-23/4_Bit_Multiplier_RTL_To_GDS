`timescale 1ns/1ps
//testbench for full adder
module tb_full_adder;
    reg        a, b, cin;
    wire       sum, cout;
    reg  [1:0] expected;

    integer k;
    integer vectors = 0;
    integer errors  = 0;

    full_adder dut (
        .a   (a),
        .b   (b),
        .cin (cin),
        .sum (sum),
        .cout(cout)
    );

    initial begin
        for (k = 0; k < 8; k = k + 1) begin
            {a, b, cin} = k;
            expected    = a + b + cin;   // 2-bit result: {cout, sum}
            #10;
            vectors = vectors + 1;
            if ({cout, sum} !== expected) begin
                errors = errors + 1;
                $display("MISMATCH: a=%b b=%b cin=%b -> cout=%b sum=%b, expected cout=%b sum=%b",
                         a, b, cin, cout, sum, expected[1], expected[0]);
            end
        end

        if (errors == 0)
            $display("PASS: %0d vectors checked, 0 errors", vectors);
        else
            $display("FAIL: %0d vectors checked, %0d errors", vectors, errors);
        $finish;
    end
endmodule
