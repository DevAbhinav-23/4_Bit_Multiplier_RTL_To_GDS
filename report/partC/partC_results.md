# Part C results

Typical corner `sky130_fd_sc_hd__tt_025C_1v80`, input/output delay 1.0 ns.

| Metric | Value |
|---|---|
| Worst slack at T = 10 ns (ns) | 7.027 |
| T_min (ns) | 10 − 7.027 = 2.973 → 2.97 |
| F_max (MHz) | 1000 / 2.97 = 336.70 |
| Slack at T = T_min (ns) | −0.003 (≈ 0, rounding of T_min to 0.01 ns) |
| Critical path start point | `_108_` (`b_r[0]` input register, `dfrtp_1`) |
| Critical path end point | `_103_` (`p[7]` output register, D = `c[3][4]`, `dfrtp_1`) |
| Number of cells on the critical path | 10 (2 flip-flops + 8 logic cells) |
| Latency (ns) = 2 × T_min | 5.94 |
| Throughput (million results per second) | 336.70 |

## Critical path cells (T = 10 ns run)

| # | Instance | Cell | Delay (ns) | Arrival (ns) |
|---|---|---|---|---|
| 1 | `_108_` | `dfrtp_1` (clk → Q) | 0.410 | 0.410 |
| 2 | `_050_` | `and4_1` | 0.223 | 0.634 |
| 3 | `_061_` | `o21ai_0` | 0.195 | 0.828 |
| 4 | `_062_` | `nand3_1` | 0.140 | 0.969 |
| 5 | `_063_` | `maj3_1` | 0.380 | 1.349 |
| 6 | `_069_` | `xnor3_1` | 0.393 | 1.741 |
| 7 | `_074_` | `maj3_1` | 0.369 | 2.110 |
| 8 | `_086_` | `maj3_1` | 0.383 | 2.493 |
| 9 | `_087_` | `maj3_1` | 0.349 | 2.842 |
| 10 | `_103_` | `dfrtp_1` (setup 0.131) | — | — |

Full-adder cells on the path: 5 (4 × `maj3` carry, 1 × `xnor3` sum), against the
estimate of 2N = 8 full-adder delays. ABC restructured the adders, and the path
mostly follows the carry outputs (`maj3`) instead of each adder's sum.

## Files

- `sta_T10.log`, `mult_array_timing_T10.rpt`: run at T = 10 ns
- `sta_Tmin.log`, `mult_array_timing_Tmin.rpt`: run at T = 2.97 ns (same as `sta/mult_array_timing.rpt`)
