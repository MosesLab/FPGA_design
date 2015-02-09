set myProject "ref_design_fcg006rd.ise"
set myScript "ref_design.tcl"

# 
# Main (top-level) routines
# 

# 
# run_process
# This procedure is used to run processes on an existing project. You may comment or
# uncomment lines to control which processes are run. This routine is set up to run
# the Implement Design and Generate Programming File processes by default. This proc
# also sets process properties as specified in the "set_process_props" proc. Only
# those properties which have values different from their current settings in the project
# file will be modified in the project.
# 

proc run_synthesis {} {

   global myScript
   global myProject

   ## put out a 'heartbeat' - so we know something's happening.
   puts "\n$myScript: synthesizing ($myProject)...\n"

   if { ! [ open_project ] } {
      return false
   }

   puts "Running 'Synthesis'"
   if { ! [ process run "Synthesize" ] } {
      puts "$myScript: Synthesize failed, check run output for details."
      project close
      return
   }

   puts "Synthesis completed."
   project close
}

proc rebuild_and_implement {} {
	rebuild_project
	run_process
}

proc run_process {} {

   global myScript
   global myProject

   ## put out a 'heartbeat' - so we know something's happening.
   puts "\n$myScript: running ($myProject)...\n"

   if { ! [ open_project ] } {
      return false
   }

   #
   # Remove the comment characters (#'s) to enable the following commands 
   # process run "Synthesize"
   # process run "Translate"
   # process run "Map"
   # process run "Place & Route"
   #
   puts "Running 'Implement Design'"
   if { ! [ process run "Implement Design" ] } {
      puts "$myScript: Implementation run failed, check run output for details."
      project close
      return
   }
   puts "Running 'Generate Programming File'"
   if { ! [ process run "Generate Programming File" ] } {
      puts "$myScript: Generate Programming File run failed, check run output for details."
      project close
      return
   }

   puts "Run completed."
   project close

}

# 
# rebuild_project
# 
# This procedure renames the project file (if it exists) and recreates the project.
# It then sets project properties and adds project sources as specified by the
# set_project_props and add_source_files support procs. It recreates VHDL libraries
# and partitions as they existed at the time this script was generated.
# 
# It then calls run_process to set process properties and run selected processes.
# 
proc rebuild_project {} {

   global myScript
   global myProject

   ## put out a 'heartbeat' - so we know something's happening.
   puts "\n$myScript: rebuilding ($myProject)...\n"

   if { [ file exists $myProject ] } { 
      puts "$myScript: Removing existing project file."
      file delete $myProject
   }

   puts "$myScript: Rebuilding project $myProject"
   project new $myProject
   set_project_props
   add_source_files
   create_libraries
   create_partitions
   set_process_props
   puts "$myScript: project rebuild completed."

	project close
}

# 
# Support Routines
# 

# 
# show_help: print information to help users understand the options available when
#            running this script.
# 
proc show_help {} {

   global myScript

   puts ""
   puts "usage: xtclsh $myScript <options>"
   puts "       or you can run xtclsh and then enter 'source $myScript'."
   puts ""
   puts "options:"
   puts "   run_process       - set properties and run processes."
   puts "   rebuild_project   - rebuild the project from scratch and run processes."
   puts "   set_project_props - set project properties (device, speed, etc.)"
   puts "   add_source_files  - add source files"
   puts "   create_libraries  - create vhdl libraries"
   puts "   create_partitions - create partitions"
   puts "   set_process_props - set process property values"
   puts "   show_help         - print this message"
   puts ""
}

proc open_project {} {

   global myScript
   global myProject

   if { ! [ file exists $myProject ] } { 
      ## project file isn't there, rebuild it.
      puts "Project $myProject not found. Use project_rebuild to recreate it."
      return false
   }

   project open $myProject

   return true

}
# 
# set_project_props
# 
# This procedure sets the project properties as they were set in the project
# at the time this script was generated.
# 
proc set_project_props {} {

   global myScript

   if { ! [ open_project ] } {
      return false
   }

   puts "$myScript: Setting project properties..."

   project set family "Virtex5"
   project set device "xc5vlx50t"
   project set package "ff665"
   project set speed "-1"
   project set top_level_module_type "HDL"
   project set synthesis_tool "XST (VHDL/Verilog)"
   project set simulator "Modelsim-XE VHDL"
   project set "Preferred Language" "VHDL"
   project set "Enable Message Filtering" "true"
   project set "Display Incremental Messages" "true"

}


# 
# add_source_files
# 
# This procedure add the source files that were known to the project at the
# time this script was generated.
# 
proc add_source_files {} {

   global myScript

   if { ! [ open_project ] } {
      return false
   }

   puts "$myScript: Adding sources to project..."

   xfile add "../../source/common/Xto1Mux_32.vhd"
   xfile add "../../source/common/ctiSim.vhd"
   xfile add "../../source/common/ctiUtil.vhd"
   xfile add "../../source/common/regBank_32.vhd"
   xfile add "../../source/common/shiftRegXX.vhd"
   xfile add "../../source/common/txt_util.vhd"
   xfile add "../../source/constraints/ffpci104_fcg006rd.ucf"
   xfile add "../../source/eeprom/eepromMaster.vhd"
   xfile add "../../source/emac/ICMPPROG.VHD"
   xfile add "../../source/emac/emacICMP.vhd"
   xfile add "../../source/emac/emacRx.vhd"
   xfile add "../../source/emac/emacTx.vhd"
   xfile add "../../source/emac/emac_init.vhd"
   xfile add "../../source/plxControl/plx32BitMaster.vhd"
   xfile add "../../source/plxControl/plx32BitSlave.vhd"
   xfile add "../../source/plxControl/plxArb.vhd"
   xfile add "../../source/plxControl/plxBusMonitor.vhd"
   xfile add "../../source/plxControl/plxCfgRom.vhd"
   xfile add "../../source/rocketio/example_tb.vhd"
   xfile add "../../source/rocketio/gtp_frame_rx.vhd"
   xfile add "../../source/rocketio/gtp_frame_tx.vhd"
   xfile add "../../source/rocketio/mgt_tester.vhd"
   xfile add "../../source/rocketio/pciegtp_wrapper.vhd"
   xfile add "../../source/rocketio/pciegtp_wrapper_tile.vhd"
   xfile add "../../source/serial/bbfifo_16x8.vhd"
   xfile add "../../source/serial/kcuart_rx.vhd"
   xfile add "../../source/serial/kcuart_tx.vhd"
   xfile add "../../source/serial/serialSimple.vhd"
   xfile add "../../source/serial/uart_rx.vhd"
   xfile add "../../source/serial/uart_tx_plus.vhd"
   xfile add "../../source/spiFlash32/PBPROGF2.VHD"
   xfile add "../../source/spiFlash32/ctiSPIf2.vhd"
   xfile add "../../source/spiFlash32/kcpsm3.vhd"
   xfile add "../../source/spiFlash32/spi_module_cti.vhd"
   xfile add "../../source/topRefDesign/ref_design.vhd"
   xfile add "../../source/topRefDesign/ref_design_fcg006rd_pkg.vhd"
   xfile add "../../source/v5Clock/clkControlMem.vhd"
   xfile add "../../source/v5Clock/clkfwd_mod.vhd"
   xfile add "../../source/v5Config/v5InternalConfig.vhd"
   xfile add "../../source/v5Coregen/dpRam32_8.xco"
   xfile add "../../source/v5Coregen/dp_32_64.xco"
   xfile add "../../source/v5Coregen/fifo_42x16.xco"
   xfile add "../../source/v5coregen/dp_a256x8_b256x8.xco"
   xfile add "../../source/v5coregen/dp_a32x8_b8x32.xco"
   xfile add "../../source/v5coregen/dpa64x8_b16x32.xco"
   xfile add "../../source/v5coregen/gen200Mhz.vhd"
   xfile add "../../source/v5coregen/lclkDeskew.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/ddr2_interface.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/mig20_app.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/mig20_ctrl_0.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/mig20_ddr2_top_0.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/mig20_idelay_ctrl.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/mig20_infrastructure.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/mig20_mem_if_top_0.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/mig20_phy_calib_0.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/mig20_phy_ctl_io_0.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/mig20_phy_dm_iob.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/mig20_phy_dq_iob.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/mig20_phy_dqs_iob.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/mig20_phy_init_0.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/mig20_phy_io_0.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/mig20_phy_top_0.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/mig20_phy_write_0.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/mig20_usr_addr_fifo_0.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/mig20_usr_rd_0.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/mig20_usr_top_0.vhd"
   xfile add "../../source/v5coregen/mig20/user_design/rtl/mig20_usr_wr_0.vhd"
   xfile add "../../source/v5coregen/pciegtx_wrapper/src/mgt_usrclk_source_pll.vhd"
   xfile add "../../source/v5coregen/pciegtx_wrapper/src/pciegtx_wrapper.vhd"
   xfile add "../../source/v5coregen/pciegtx_wrapper/src/pciegtx_wrapper_tile.vhd"
   xfile add "../../source/v5coregen/v5_emac_v1_3/example_design/client/fifo/eth_fifo_8.vhd"
   xfile add "../../source/v5coregen/v5_emac_v1_3/example_design/client/fifo/rx_client_fifo_8.vhd"
   xfile add "../../source/v5coregen/v5_emac_v1_3/example_design/client/fifo/tx_client_fifo_8.vhd"
   xfile add "../../source/v5coregen/v5_emac_v1_3/example_design/physical/mii_if.vhd"
   xfile add "../../source/v5coregen/v5_emac_v1_3/example_design/v5_emac_v1_3.vhd"
   xfile add "../../source/v5coregen/v5_emac_v1_3/example_design/v5_emac_v1_3_block.vhd"
   xfile add "../../source/v5coregen/v5_emac_v1_3/example_design/v5_emac_v1_3_locallink.vhd"

   # Set the Top Module as well...
   project set top "rtl" "ref_design"

   puts "$myScript: project sources reloaded."

} ; # end add_source_files

# 
# create_libraries
# 
# This procedure defines VHDL libraries and associates files with those libraries.
# It is expected to be used when recreating the project. Any libraries defined
# when this script was generated are recreated by this procedure.
# 
proc create_libraries {} {

   global myScript

   if { ! [ open_project ] } {
      return false
   }

   puts "$myScript: Creating libraries..."
   # note: if you have multiple files with the same name at different paths,
   # you may have problems with the lib_vhdl command.


   # must close the project or library definitions aren't saved, then reopen it for further use.
   project close
   open_project

} ; # end create_libraries

#
# create_partitions
#
# This procedure creates partitions on instances in your project.
# It is expected to be used when recreating the project. Any partitions
# defined when this script was generated are recreated by this procedure.
# 
proc create_partitions {} {

   global myScript

   if { ! [ open_project ] } {
      return false
   }

   puts "$myScript: Creating Partitions..."


   # must close the project or partition definitions aren't saved, then reopen it for further use.
   project close
   open_project

} ; # end create_partitions

# 
# set_process_props
# 
# This procedure sets properties as requested during script generation (either
# all of the properties, or only those modified from their defaults).
# 
proc set_process_props {} {

   global myScript

   if { ! [ open_project ] } {
      return false
   }

   puts "$myScript: setting process properties..."

   project set "Compiled Library Directory" "\$XILINX/<language>/<simulator>"
   project set "Use SmartGuide" "false"
   project set "SmartGuide Filename" "ref_design_guide.ncd"
   project set "Map to Input Functions" "6" -process "Map"
   project set "Pack I/O Registers/Latches into IOBs" "Off" -process "Map"
   project set "Place And Route Mode" "Route Only" -process "Place & Route"
   project set "Number of Clock Buffers" "32" -process "Synthesize - XST"
   project set "Max Fanout" "100000" -process "Synthesize - XST"
   project set "Use Clock Enable" "Auto" -process "Synthesize - XST"
   project set "Use Synchronous Reset" "Auto" -process "Synthesize - XST"
   project set "Use Synchronous Set" "Auto" -process "Synthesize - XST"
   project set "Placer Effort Level" "High" -process "Map"
   project set "Global Optimization" "false" -process "Map"
   project set "LUT Combining" "Off" -process "Map"
   project set "Combinatorial Logic Optimization" "false" -process "Map"
   project set "Starting Placer Cost Table (1-100)" "1" -process "Map"
   project set "Power Reduction" "false" -process "Map"
   project set "Register Duplication" "false" -process "Map"
   project set "Reduce Control Sets" "No" -process "Synthesize - XST"
   project set "Case Implementation Style" "None" -process "Synthesize - XST"
   project set "Decoder Extraction" "true" -process "Synthesize - XST"
   project set "Priority Encoder Extraction" "Yes" -process "Synthesize - XST"
   project set "Mux Extraction" "Yes" -process "Synthesize - XST"
   project set "RAM Extraction" "true" -process "Synthesize - XST"
   project set "ROM Extraction" "true" -process "Synthesize - XST"
   project set "FSM Encoding Algorithm" "Auto" -process "Synthesize - XST"
   project set "Logical Shifter Extraction" "true" -process "Synthesize - XST"
   project set "Optimization Goal" "Speed" -process "Synthesize - XST"
   project set "Optimization Effort" "High" -process "Synthesize - XST"
   project set "Resource Sharing" "true" -process "Synthesize - XST"
   project set "Shift Register Extraction" "true" -process "Synthesize - XST"
   project set "XOR Collapsing" "true" -process "Synthesize - XST"
   project set "Other Bitgen Command Line Options" "" -process "Generate Programming File"
   project set "Generate Detailed Package Parasitics" "false" -process "Generate IBIS Model"
   project set "Show All Models" "false" -process "Generate IBIS Model"
   project set "Target UCF File Name" "" -process "Back-annotate Pin Locations"
   project set "Ignore User Timing Constraints" "false" -process "Map"
   project set "Use RLOC Constraints" "true" -process "Map"
   project set "Other Map Command Line Options" "" -process "Map"
   project set "Use LOC Constraints" "true" -process "Translate"
   project set "Other Ngdbuild Command Line Options" "" -process "Translate"
   project set "Ignore User Timing Constraints" "false" -process "Place & Route"
   project set "Other Place & Route Command Line Options" "" -process "Place & Route"
   project set "Use DSP Block" "Auto" -process "Synthesize - XST"
   project set "BPI Reads Per Page" "1" -process "Generate Programming File"
   project set "Configuration Pin Busy" "Pull Up" -process "Generate Programming File"
   project set "Configuration Clk (Configuration Pins)" "Pull Up" -process "Generate Programming File"
   project set "UserID Code (8 Digit Hexadecimal)" "0xaa00bb11" -process "Generate Programming File"
   project set "Configuration Pin CS" "Pull Up" -process "Generate Programming File"
   project set "DCI Update Mode" "As Required" -process "Generate Programming File"
   project set "Configuration Pin DIn" "Pull Up" -process "Generate Programming File"
   project set "Configuration Pin Done" "Pull Up" -process "Generate Programming File"
   project set "Create ASCII Configuration File" "false" -process "Generate Programming File"
   project set "Create Binary Configuration File" "false" -process "Generate Programming File"
   project set "Create Bit File" "true" -process "Generate Programming File"
   project set "Enable BitStream Compression" "false" -process "Generate Programming File"
   project set "Run Design Rules Checker (DRC)" "true" -process "Generate Programming File"
   project set "Enable Cyclic Redundancy Checking (CRC)" "true" -process "Generate Programming File"
   project set "Create IEEE 1532 Configuration File" "false" -process "Generate Programming File"
   project set "Create ReadBack Data Files" "true" -process "Generate Programming File"
   project set "Configuration Pin Init" "Pull Up" -process "Generate Programming File"
   project set "Configuration Pin M0" "Pull Up" -process "Generate Programming File"
   project set "Configuration Pin M1" "Pull Up" -process "Generate Programming File"
   project set "Configuration Pin M2" "Pull Up" -process "Generate Programming File"
   project set "Configuration Pin Program" "Pull Up" -process "Generate Programming File"
   project set "Power Down Device if Over Safe Temperature" "false" -process "Generate Programming File"
   project set "Configuration Rate" "20" -process "Generate Programming File"
   project set "Configuration Pin RdWr" "Pull Up" -process "Generate Programming File"
   project set "Retain Configuration Status Register Values after Reconfiguration" "true" -process "Generate Programming File"
   project set "SelectMAP Abort Sequence" "Enable" -process "Generate Programming File"
   project set "JTAG Pin TCK" "Pull Up" -process "Generate Programming File"
   project set "JTAG Pin TDI" "Pull Up" -process "Generate Programming File"
   project set "JTAG Pin TDO" "Pull Up" -process "Generate Programming File"
   project set "JTAG Pin TMS" "Pull Up" -process "Generate Programming File"
   project set "Unused IOB Pins" "Pull Down" -process "Generate Programming File"
   project set "Security" "Enable Readback and Reconfiguration" -process "Generate Programming File"
   project set "Done (Output Events)" "Default (4)" -process "Generate Programming File"
   project set "Drive Done Pin High" "false" -process "Generate Programming File"
   project set "Enable Outputs (Output Events)" "Default (5)" -process "Generate Programming File"
   project set "Match Cycle" "Auto" -process "Generate Programming File"
   project set "Release DLL (Output Events)" "Default (NoWait)" -process "Generate Programming File"
   project set "Release Write Enable (Output Events)" "Default (6)" -process "Generate Programming File"
   project set "FPGA Start-Up Clock" "CCLK" -process "Generate Programming File"
   project set "Enable Internal Done Pipe" "false" -process "Generate Programming File"
   project set "Allow Logic Optimization Across Hierarchy" "false" -process "Map"
   project set "Optimization Strategy (Cover Mode)" "Speed" -process "Map"
   project set "Disable Register Ordering" "false" -process "Map"
   project set "Maximum Compression" "false" -process "Map"
   project set "Replicate Logic to Allow Logic Level Reduction" "true" -process "Map"
   project set "Generate Detailed MAP Report" "false" -process "Map"
   project set "Map Slice Logic into Unused Block RAMs" "false" -process "Map"
   project set "Trim Unconnected Signals" "true" -process "Map"
   project set "Create I/O Pads from Ports" "false" -process "Translate"
   project set "Macro Search Path" "../../source/v5chipscope | ../../source/v5coregen" -process "Translate"
   project set "Netlist Translation Type" "Timestamp" -process "Translate"
   project set "User Rules File for Netlister Launcher" "" -process "Translate"
   project set "Allow Unexpanded Blocks" "false" -process "Translate"
   project set "Allow Unmatched LOC Constraints" "false" -process "Translate"
   project set "Starting Placer Cost Table (1-100)" "1" -process "Place & Route"
   project set "Use Bonded I/Os" "false" -process "Place & Route"
   project set "Add I/O Buffers" "true" -process "Synthesize - XST"
   project set "Global Optimization Goal" "AllClockNets" -process "Synthesize - XST"
   project set "Keep Hierarchy" "No" -process "Synthesize - XST"
   project set "Register Balancing" "No" -process "Synthesize - XST"
   project set "Register Duplication" "true" -process "Synthesize - XST"
   project set "Asynchronous To Synchronous" "false" -process "Synthesize - XST"
   project set "Automatic BRAM Packing" "false" -process "Synthesize - XST"
   project set "BRAM Utilization Ratio" "100" -process "Synthesize - XST"
   project set "Bus Delimiter" "<>" -process "Synthesize - XST"
   project set "Case" "Maintain" -process "Synthesize - XST"
   project set "Cores Search Directories" "../../source/v5chipscope | ../../source/v5coregen" -process "Synthesize - XST"
   project set "Cross Clock Analysis" "false" -process "Synthesize - XST"
   project set "DSP Utilization Ratio" "100" -process "Synthesize - XST"
   project set "Equivalent Register Removal" "true" -process "Synthesize - XST"
   project set "FSM Style" "LUT" -process "Synthesize - XST"
   project set "Generate RTL Schematic" "Yes" -process "Synthesize - XST"
   project set "Generics, Parameters" "" -process "Synthesize - XST"
   project set "Hierarchy Separator" "/" -process "Synthesize - XST"
   project set "HDL INI File" "" -process "Synthesize - XST"
   project set "LUT Combining" "No" -process "Synthesize - XST"
   project set "Library Search Order" "" -process "Synthesize - XST"
   project set "Netlist Hierarchy" "As Optimized" -process "Synthesize - XST"
   project set "Optimize Instantiated Primitives" "false" -process "Synthesize - XST"
   project set "Pack I/O Registers into IOBs" "Auto" -process "Synthesize - XST"
   project set "Power Reduction" "false" -process "Synthesize - XST"
   project set "Read Cores" "true" -process "Synthesize - XST"
   project set "Slice Packing" "true" -process "Synthesize - XST"
   project set "LUT-FF Pairs Utilization Ratio" "100" -process "Synthesize - XST"
   project set "Use Synthesis Constraints File" "true" -process "Synthesize - XST"
   project set "Custom Compile File List" "" -process "Synthesize - XST"
   project set "Verilog Include Directories" "" -process "Synthesize - XST"
   project set "Verilog 2001" "true" -process "Synthesize - XST"
   project set "Verilog Macros" "" -process "Synthesize - XST"
   project set "Work Directory" "./xst" -process "Synthesize - XST"
   project set "Write Timing Constraints" "false" -process "Synthesize - XST"
   project set "Other XST Command Line Options" "" -process "Synthesize - XST"
   project set "Timing Mode" "Performance Evaluation" -process "Map"
   project set "Generate Asynchronous Delay Report" "false" -process "Place & Route"
   project set "Generate Clock Region Report" "false" -process "Place & Route"
   project set "Generate Post-Place & Route Simulation Model" "false" -process "Place & Route"
   project set "Generate Post-Place & Route Static Timing Report" "true" -process "Place & Route"
   project set "Nodelist File (Unix Only)" "" -process "Place & Route"
   project set "Number of PAR Iterations (0-100)" "3" -process "Place & Route"
   project set "Save Results in Directory (.dir will be appended)" "" -process "Place & Route"
   project set "Number of Results to Save (0-100)" "" -process "Place & Route"
   project set "Power Reduction" "false" -process "Place & Route"
   project set "Place & Route Effort Level (Overall)" "High" -process "Place & Route"
   project set "Equivalent Register Removal" "true" -process "Map"
   project set "Placer Extra Effort" "Continue on Impossible" -process "Map"
   project set "Power Activity File" "" -process "Map"
   project set "Retiming" "false" -process "Map"
   project set "Synthesis Constraints File" "" -process "Synthesize - XST"
   project set "Mux Style" "Auto" -process "Synthesize - XST"
   project set "RAM Style" "Auto" -process "Synthesize - XST"
   project set "Encrypt Bitstream" "false" -process "Generate Programming File"
   project set "Timing Mode" "Performance Evaluation" -process "Place & Route"
   project set "Cycles for First BPI Page Read" "2" -process "Generate Programming File"
   project set "Enable Debugging of Serial Mode BitStream" "false" -process "Generate Programming File"
   project set "Create Logic Allocation File" "false" -process "Generate Programming File"
   project set "Create Mask File" "true" -process "Generate Programming File"
   project set "Allow SelectMAP Pins to Persist" "false" -process "Generate Programming File"
   project set "Move First Flip-Flop Stage" "true" -process "Synthesize - XST"
   project set "Move Last Flip-Flop Stage" "true" -process "Synthesize - XST"
   project set "ROM Style" "Auto" -process "Synthesize - XST"
   project set "Safe Implementation" "No" -process "Synthesize - XST"
   project set "Power Activity File" "" -process "Place & Route"
   project set "Extra Effort (Highest PAR level only)" "Normal" -process "Place & Route"
   project set "Key 0 (Hex String)" "" -process "Generate Programming File"
   project set "Input Encryption Key File" "" -process "Generate Programming File"
   project set "Fallback Reconfiguration" "Enable" -process "Generate Programming File"

   puts "$myScript: project property values set."

} ; # end set_process_props

proc main {} {

   if { [llength $::argv] == 0 } {
      show_help
      return true
   }

   foreach option $::argv {
      switch $option {
         "show_help"           { show_help }
         "run_process"         { run_process }
         "rebuild_project"     { rebuild_project }
         "set_project_props"   { set_project_props }
         "add_source_files"    { add_source_files }
         "create_libraries"    { create_libraries }
         "create_partitions"   { create_partitions }
         "set_process_props"   { set_process_props }
		 "rebuild_and_implement"   { rebuild_and_implement}
		 "run_synthesis"   		{ run_synthesis }
         default               { puts "unrecognized option: $option"; show_help }
      }
   }
}

if { $tcl_interactive } {
   show_help
} else {
   if {[catch {main} result]} {
      puts "$myScript failed: $result."
   }
}
