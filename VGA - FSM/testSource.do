# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog testSource.v
vlog movingAverage.v
vlog filterInput.v
vlog Tone10RAM.v
vlog Tone400RAM.v
vlog Tone800RAM.v
vlog Tone1200RAM.v
vlog Tone1600RAM.v
vlog Tone2000RAM.v
vlog Tone2400RAM.v
vlog Tone3000RAM.v

#load simulation using mux as the top level simulation module
vsim -L altera_mf_ver testSource

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

#CASE1
#Data

force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 1

force {KEY[3]} 0
force {KEY[2]} 1
force {KEY[1]} 0
force {KEY[0]} 0

run 5ns


force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 1

force {KEY[3]} 0
force {KEY[2]} 0

force {KEY[0]} 0 0ns, 1 {1ns} -r 2ns
force {KEY[1]} 0 0ns, 1 {159ns} -r 160nS

run 100000ns

force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 1

force {KEY[3]} 1
force {KEY[2]} 1
force {KEY[0]} 0 0ns, 1 {1ns} -r 2ns
force {KEY[1]} 0 0ns, 1 {159ns} -r 160ns
run 100000ns

force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 1

force {KEY[3]} 0
force {KEY[2]} 1

force {KEY[0]} 0 0ns, 1 {1ns} -r 2ns
force {KEY[1]} 0 0ns, 1 {159ns} -r 160ns
run 100000ns




