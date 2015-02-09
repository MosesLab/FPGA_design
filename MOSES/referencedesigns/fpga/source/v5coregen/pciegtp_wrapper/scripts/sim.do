##Load Design
vsim -t 1ps -L UNISIM work.EXAMPLE_TB 


##Run simulation
set NumericStdNoWarnings 1
set StdArithNoWarnings 1

view wave
view structure
view signals

do wave.do


when "simFinished = TRUE" {stop} 