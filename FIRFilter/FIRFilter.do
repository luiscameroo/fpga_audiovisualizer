# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog FIRFilter.v

#load simulation using mux as the top level simulation module
vsim FIRFilter

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


#INITIAL STATE
force {KEY[0]} 1 
force {KEY[1]} 1 

force {SW[0]} 0 0ns, 1 {10ns} -r 20ns
run 40ns

#RESETN
force {KEY[0]} 0

force {SW[0]} 0 0ns, 1 {10ns} -r 20ns
run 40ns

force {KEY[0]} 1
force {KEY[1]} 1

force {SW[0]} 0 0ns, 1 {10ns} -r 20ns
run 40ns

#START
force {KEY[0]} 1
force {KEY[1]} 0

force {SW[0]} 0 0ns, 1 {10ns} -r 20ns
run 40ns

force {KEY[0]} 1
force {KEY[1]} 1

run 40000ns