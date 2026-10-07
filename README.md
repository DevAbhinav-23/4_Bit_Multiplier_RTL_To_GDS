# 4-bit Array Multiplier: RTL to GDSII

Individual VLSI assignment: a 4-bit x 4-bit unsigned array multiplier (8-bit product), registered inputs and outputs (2-cycle latency), taken from RTL through synthesis, STA and place and route on SkyWater SKY130 (`sky130_fd_sc_hd`).

- **Roll number:** 2024102059
- **GitHub:** DevAbhinav-23

## File structure

```
mult4_2024102059/
|-- README.md
|-- rtl/
|   |-- full_adder.v          1-bit full adder (assign statements)
|   `-- mult_array.v          4x4 array multiplier, 12 full_adder instances
|-- tb/
|   |-- tb_full_adder.v       exhaustive testbench for the full adder (8 vectors)
|   |-- tb_mult.v             exhaustive self-checking testbench (256 vectors)
|   `-- VLSI_4bit_Multiplier_Assignment_Student_Guide.pdf
|-- sim/
|   |-- full_adder_results.log
|   `-- mult_results.log
|-- mult.vcd                  waveform from tb_mult
|-- synth/                    synthesis scripts and reports (pending)
|-- sta/                      static timing analysis (pending)
|-- pnr/                      place and route (pending)
`-- report/                   final report (pending)
```

## Stack

The guide lists open-source tools (Icarus Verilog, Yosys, OpenSTA, LibreLane/OpenROAD). The server used for this work has the Cadence suite installed, and using it instead was confirmed with the assignment giver.

| Stage | Tool |
|---|---|
| RTL simulation | Icarus Verilog (`iverilog`, `vvp`) |
| Waveform viewing | GTKWave |
| Logic synthesis | Cadence Genus |
| Place and route | Cadence Innovus |
| Process / library | SkyWater SKY130, `sky130_fd_sc_hd` (tt_025C_1v80) |

## Progress

- [x] Repository structure
- [x] Full adder RTL, testbench and results: `PASS: 8 vectors checked, 0 errors`
- [x] 4-bit array multiplier RTL, testbench and results: `PASS: 256 vectors checked, 0 errors`
- [ ] Synthesis (Genus)
- [ ] Gate-level simulation
- [ ] Static timing analysis
- [ ] Place and route (Innovus), DRC / LVS
- [ ] Report

## Commands run

Full adder:

```
iverilog -g2012 -o sim_fa tb/tb_full_adder.v rtl/full_adder.v
vvp sim_fa
```

Multiplier:

```
iverilog -g2012 -o sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
vvp sim
gtkwave mult.vcd
```

Commands for the remaining steps will be added as they are run.
