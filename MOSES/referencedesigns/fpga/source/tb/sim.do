vsim -t 1ps   -lib work init_tb
view wave
#add wave *
#do {init_tb.udo}
do wave.do
view structure
view signals
#mem load -i dmMaster.mem /init_tb/uut/u_plx32bitmaster/u_blockram/u0/line__985/memory
run 1000ns
when "simFinished = TRUE" {stop} 