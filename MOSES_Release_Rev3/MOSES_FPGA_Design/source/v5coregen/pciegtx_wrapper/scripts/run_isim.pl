   
################################################################################
##$Date: 2008/05/30 00:57:53 $
##$RCSfile: run_isim_pl.ejava,v $
##$Revision: 1.1.2.1 $
################################################################################
##   ____  ____ 
##  /   /\/   / 
## /___/  \  /    Vendor: Xilinx 
## \   \   \/     Version : 1.5
##  \   \         Application : RocketIO GTX Wizard 
##  /   /         Filename : run_isim.pl
## /___/   /\     Timestamp : 11/12/2007 09:12:43
## \   \  /  \ 
##  \___\/\___\ 
##
##
## Script RUN_ISIM.PL
## Generated by Xilinx RocketIO GTX Wizard


##***************************** Beginning of Script ***************************
    
    
$top_module = "EXAMPLE_TB";
$exe_file = "$top_module.exe";
$XILINX = $ENV{XILINX};


##MGT Wrapper
push @Filelist, "../src/pciegtx_wrapper_tile.vhd";
push @Filelist, "../src/pciegtx_wrapper.vhd";

push @Filelist, "../src/mgt_usrclk_source_pll.vhd";

##Example Design modules
push @Filelist, "../example/frame_gen.vhd";
push @Filelist, "../example/frame_check.vhd";
push @Filelist, "../example/example_mgt_top.vhd";


##Other modules
push @Filelist, "../testbench/sim_reset_mgt_model.vhd";

##Testbench file
push @Filelist, "../testbench/example_tb.vhd";


#Generate PRJ file
open (PRJ_FILE, ">sim_isim.prj");
foreach $module(@Filelist)
{
print PRJ_FILE "vhdl work ". $module . "\n";
}
close (PRJ_FILE);


#Compile and link source files
system("fuse -prj sim_isim.prj -top $top_module -o $exe_file");

##--Generate waveform trace--##
system("./$exe_file -tclbatch isim_wave.tcl -wavefile isim_wave");


##--View simulation wave--##
system("isimwave isim_wave.xwv");
