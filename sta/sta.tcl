# Static timing analysis of the synthesized multiplier (typical corner only)
# Run from the repo root:  sta sta/sta.tcl
# Clock period T defaults to 10 ns; override with:  PERIOD=3.80 sta sta/sta.tcl

# Liberty timing library (typical corner)
set lib $::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

# Clock period in ns
if {[info exists ::env(PERIOD)]} {
    set T $::env(PERIOD)
} else {
    set T 10.0
}

# 1. Read the cell timing library
read_liberty $lib

# 2. Read and link the netlist
read_verilog synth/mult_array_netlist.v
link_design mult_array

# 3. Define the clock
create_clock -name clk -period $T [get_ports clk]

# 4. Input arrival time (all inputs except clk)
set_input_delay 1.0 -clock clk [delete_from_list [all_inputs] [get_ports clk]]

# 5. Output required time
set_output_delay 1.0 -clock clk [all_outputs]

# 6. Print the worst setup slack
puts "Clock period T = $T ns"
report_worst_slack -max

# 7. Save the critical path report
report_checks -path_delay max -digits 3 > sta/mult_array_timing.rpt

exit
