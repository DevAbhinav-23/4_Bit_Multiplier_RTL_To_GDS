
// 4x4 unsigned array multiplier, registered inputs and output (latency 2)
// 16 AND gates + 12 full adders (rows 1..3, 4 FAs each). No '*' operator.
module mult_array (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] a,
    input  wire [3:0] b,
    output reg  [7:0] p
);
    // ---------------- input registers (8 flip-flops) ----------------
    reg [3:0] a_r, b_r;

    // ---------------- partial products: pp[i][j] = a[j] & b[i] -------
    wire [3:0] pp [0:3];
    genvar i, j;
    generate
        for (i = 0; i < 4; i = i + 1) begin : g_pp
            assign pp[i] = a_r & {4{b_r[i]}};
        end
    endgenerate

    // ---------------- adder rows ----------------
    // r[i]  : 4 bits passed down from row i to row i+1
    // s[i]  : sum outputs of row i,  c[i] : carry chain of row i
    wire [3:0] r [0:3];
    wire [3:0] s [1:3];
    wire [4:0] c [1:3];
    wire [7:0] p_comb;

    // Row 0: AND gates only
    assign p_comb[0] = pp[0][0];
    assign r[0]      = {1'b0, pp[0][3], pp[0][2], pp[0][1]};

    // Rows 1..3: 4-bit ripple-carry adder adding pp[i] to r[i-1]
    generate
        for (i = 1; i < 4; i = i + 1) begin : g_row
            assign c[i][0] = 1'b0;
            for (j = 0; j < 4; j = j + 1) begin : g_fa
                full_adder fa (
                    .a   (pp[i][j]),
                    .b   (r[i-1][j]),
                    .cin (c[i][j]),
                    .sum (s[i][j]),
                    .cout(c[i][j+1])
                );
            end
            assign p_comb[i] = s[i][0];
            assign r[i]      = {c[i][4], s[i][3], s[i][2], s[i][1]};
        end
    endgenerate

    // Last row gives the top four product bits
    assign p_comb[7:4] = r[3];

    // ---------------- registers (16 flip-flops total) ----------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_r <= 4'd0;
            b_r <= 4'd0;
            p   <= 8'd0;
        end else begin
            a_r <= a;
            b_r <= b;
            p   <= p_comb;
        end
    end
endmodule

