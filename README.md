# 4-bit Array Multiplier: RTL to GDSII

DVD assignment: a 4-bit x 4-bit unsigned array multiplier (8-bit product), registered inputs and outputs (2-cycle latency), taken from RTL through synthesis, STA and place and route on SkyWater SKY130 (`sky130_fd_sc_hd`).

## File structure

```
mult4_2024102059/
|-- README.md
|-- rtl/
|   |-- full_adder.v          1-bit full adder (assign statements)
|   `-- mult_array.v          4x4 array multiplier, 12 full_adder instances
|-- tb/
|   `-- tb_mult.v             exhaustive self-checking testbench (256 vectors)
|-- mult.vcd                  waveform from tb_mult
|-- synth/
|   |-- synth.tcl             Yosys synthesis script
|   |-- mult_array_netlist.v  gate-level netlist (generated)
|   `-- mult_array_stat.rpt   cell and area report (generated)
|-- sta/                      static timing analysis (pending)
|-- pnr/                      place and route (pending)
`-- report/
    |-- partA/                mult_results.log (PASS), mult_fail_results.log (task 6 FAIL test),
    |                         waveform_14x7.png, hand_example_14x7.png, block_diagram.png
    |-- partB/                synth.log, gls_results.log (gate-level PASS), partB_results.md (Part B table)
    |-- partC/                Part C table, critical-path cells (pending)
    |-- partD/                KLayout screenshots, Part D table (pending)
    `-- report.pdf            final report (pending)
```

## Stack

Only open-source tools are used, installed locally (no Docker).

| Stage | Tool |
|---|---|
| RTL simulation | Icarus Verilog (`iverilog`, `vvp`) |
| Waveform viewing | GTKWave |
| Logic synthesis | Yosys |
| Static timing analysis | OpenSTA |
| RTL-to-GDSII flow | LibreLane (OpenROAD, Magic, KLayout, Netgen) |
| Process / library | SkyWater SKY130, `sky130_fd_sc_hd` (tt_025C_1v80) |

## Progress

- [x] Repository structure
- [x] 4-bit array multiplier RTL, testbench and results: `PASS: 256 vectors checked, 0 errors`
- [x] Testbench error check (`sum = a ^ b`): `FAIL: 256 vectors checked, 95 errors`
- [x] Synthesis (Yosys): 68 cells, 16 flip-flops, 785.754 µm²
- [x] Gate-level simulation: `PASS: 256 vectors checked, 0 errors`
- [ ] Static timing analysis
- [ ] Place and route (LibreLane), DRC / LVS
- [ ] Report

## Commands run

Part A, RTL simulation:

```
iverilog -g2012 -o sim_mult tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
vvp sim_mult > report/partA/mult_results.log
gtkwave mult.vcd
```

Testbench error check (task 6): `sum` in `rtl/full_adder.v` temporarily changed to `a ^ b`, then reverted:

```
iverilog -g2012 -o sim_mult tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
vvp sim_mult > report/partA/mult_fail_results.log
```

Part B, synthesis (run from the repository root after `source ~/eda/env.sh`):

```
yosys -c synth/synth.tcl | tee report/partB/synth.log
```

Part B, gate-level simulation:

```
CELLS=$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/verilog
iverilog -g2012 -DFUNCTIONAL -DUNIT_DELAY=#1 -o gls tb/tb_mult.v $CELLS/primitives.v $CELLS/sky130_fd_sc_hd.v synth/mult_array_netlist.v
vvp gls > report/partB/gls_results.log
```

Commands for the remaining steps will be added as they are run.

