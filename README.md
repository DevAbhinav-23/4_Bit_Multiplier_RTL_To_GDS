# 4-bit Array Multiplier: RTL to GDSII

Digital VLSI Design assignment: a 4-bit x 4-bit unsigned array multiplier (8-bit product) with registered inputs and output (16 flip-flops, 2-cycle latency). It is taken from RTL through synthesis, static timing analysis and place and route to a GDSII layout on SkyWater SKY130 (`sky130_fd_sc_hd`), using only open-source tools.

## Team

| Name | Roll number | Contribution |
|---|---|---|
| Nikhil Venkat Atkuru | 2024102039 | Part B, Part D, questions and report |
| Abhinav Venkata Kota | 2024102059 | Part A, Part C, questions and report |

## File structure

```
4_Bit_Multiplier_RTL_To_GDS/
|-- README.md
|-- rtl/
|   |-- full_adder.v              module full_adder (assign statements)
|   `-- mult_array.v              module mult_array, 12 full_adder instances, no '*'
|-- tb/
|   `-- tb_mult.v                 module tb_mult, exhaustive self-checking (256 vectors)
|-- synth/
|   |-- synth.tcl                 Yosys script
|   |-- mult_array_netlist.v      (generated)
|   `-- mult_array_stat.rpt       (generated)
|-- sta/
|   |-- sta.tcl                   OpenSTA script
|   `-- mult_array_timing.rpt     (generated, T = T_min run)
|-- pnr/
|   |-- config.json               LibreLane configuration
|   |-- metrics.json              (copied from the final run)
|   `-- mult_array.gds            (copied from the final run)
`-- report/
    `-- report.pdf                final report: results tables, screenshots, answers to Q1-Q6
```

Only these files are committed. Everything else (the `pnr/runs/` folders, simulation outputs, the assignment handout, and the logs and screenshots kept locally under `report/`) is listed in `.gitignore`.

## Tools

All tools are open source and installed locally (no Docker).

| Stage | Tool |
|---|---|
| RTL and gate-level simulation | Icarus Verilog (`iverilog`, `vvp`) |
| Waveform viewing | GTKWave |
| Logic synthesis | Yosys |
| Static timing analysis | OpenSTA 2.7.0 |
| RTL-to-GDSII flow | LibreLane 3.0.16 (OpenROAD, Magic, KLayout, Netgen) |
| PDK / library | SkyWater SKY130 (`sky130A`), `sky130_fd_sc_hd`, typical corner `tt_025C_1v80` |

Environment setup, done once in every new terminal:

```
source ~/eda/env.sh     # puts iverilog, yosys, gtkwave, librelane on PATH; sets PDK_ROOT and PDK=sky130A
eda-shell               # LibreLane nix shell, needed for sta, openroad, netgen and klayout
```

Tool check:

```
iverilog -V | head -1
yosys -V
sta -version
echo $PDK_ROOT $PDK
```

## Commands run, in order

Every command is run from the repository root unless it says `cd pnr`.

### Part A: RTL design and verification

RTL simulation (all 256 input combinations):

```
iverilog -g2012 -o sim_mult tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
vvp sim_mult > report/partA/mult_results.log
gtkwave mult.vcd
```

Result: `PASS: 256 vectors checked, 0 errors`

Testbench error check (task 6): `sum` in `rtl/full_adder.v` was temporarily changed to `a ^ b`, the simulation was run again, then the change was undone.

```
iverilog -g2012 -o sim_mult tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
vvp sim_mult > report/partA/mult_fail_results.log
```

Result: `FAIL: 256 vectors checked, 95 errors`

Worked example (task 5): A = 9 + 5 = 14 (last digit of roll number 2024102059), B = 7, product 98, shown in the waveform in Section 1.4 of `report/report.pdf`.

### Part B: Logic synthesis with Yosys

```
yosys -c synth/synth.tcl | tee report/partB/synth.log
```

Gate-level simulation of the netlist:

```
CELLS=$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/verilog
iverilog -g2012 -DFUNCTIONAL -DUNIT_DELAY=#1 -o gls \
  tb/tb_mult.v $CELLS/primitives.v $CELLS/sky130_fd_sc_hd.v synth/mult_array_netlist.v
vvp gls > report/partB/gls_results.log
```

Result: `PASS: 256 vectors checked, 0 errors`

### Part C: Static timing analysis with OpenSTA

`sta/sta.tcl` uses a 10 ns clock by default; the `PERIOD` environment variable overrides it. Run inside `eda-shell`.

Run at T = 10 ns:

```
sta sta/sta.tcl | tee report/partC/sta_T10.log
cp sta/mult_array_timing.rpt report/partC/mult_array_timing_T10.rpt
```

Worst slack 7.027 ns, so T_min = 10 - 7.027 = 2.97 ns. Run again at T = T_min:

```
PERIOD=2.97 sta sta/sta.tcl | tee report/partC/sta_Tmin.log
cp sta/mult_array_timing.rpt report/partC/mult_array_timing_Tmin.rpt
```

Slack -0.003 ns (about 0). `sta/mult_array_timing.rpt` is the report from this T = T_min run.

### Part D: Physical design with LibreLane

Starting `CLOCK_PERIOD` = 1.2 x 2.97 = 3.564 ns, rounded up to the next 0.5 ns = 4.0 ns. Each run uses the same command; only `CLOCK_PERIOD` in `pnr/config.json` was changed between runs (log of run N saved as `report/partD/librelane_runN.log`):

```
cd pnr
librelane config.json 2>&1 | tee ../report/partD/librelane_runN.log
```

Every attempt (setup slack is the worst value over all corners, `timing__setup__ws`):

| Run | CLOCK_PERIOD (ns) | Run folder | Worst setup slack (ns) | DRC / LVS | Result |
|---|---|---|---|---|---|
| 1 | 4.0 | `RUN_2026-10-18_16-52-38` | -1.254 | 0 / 0 | fail (setup) |
| 2 | 4.5 | `RUN_2026-10-18_16-57-29` | -0.754 | 0 / 0 | fail (setup) |
| 3 | 5.0 | `RUN_2026-10-18_16-59-07` | -0.254 | 0 / 0 | fail (setup) |
| 4 | 5.5 | `RUN_2026-10-18_17-01-50` | -0.009 | 0 / 0 | fail (setup) |
| 5 | 6.0 | `RUN_2026-10-18_17-03-38` | -0.001 | 0 / 0 | fail (setup) |
| 6 | 6.0, with `"RUN_POST_GRT_RESIZER_TIMING": true` | `RUN_2026-10-18_17-06-07` | +0.043 | 0 / 0 | pass, experiment only, not used |
| 7 | 6.5 | `RUN_2026-10-18_17-09-50` | +0.499 | 0 / 0 | **pass, final** |

Run 6 was an experiment with an extra timing-repair step after global routing; the setting was removed again afterwards. The final run 7 uses only the settings required by the handout (see `pnr/config.json`).

Copy the results of the final run:

```
cp runs/RUN_2026-10-18_17-09-50/final/metrics.json .
cp runs/RUN_2026-10-18_17-09-50/final/gds/mult_array.gds .
```

View the layout (inside `eda-shell`); the two screenshots are in Section 4.6 of `report/report.pdf`:

```
klayout mult_array.gds
```

## Results summary

| Part | Result |
|---|---|
| A | `PASS: 256 vectors checked, 0 errors`; error test `FAIL: 256 vectors checked, 95 errors` |
| B | 68 cells, 16 flip-flops (`dfrtp_1`), 785.754 µm² total, flip-flops 50.96 % of area; netlist simulation PASS |
| C | T_min = 2.97 ns, F_max = 336.70 MHz, critical path `b_r[0]` to `p[7]` (10 cells), latency 5.94 ns |
| D | CLOCK_PERIOD 6.5 ns, 4822 cells, core area 17759.5 µm², wirelength 2612 µm, setup slack +0.499 ns, post-route F_max 166.65 MHz, 0 DRC errors, 0 LVS errors |

Full tables, screenshots and answers to the report questions are in `report/report.pdf`.
