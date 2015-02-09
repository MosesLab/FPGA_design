@echo off
IF EXIST "../synth/__projnav" rmdir /S /Q "../synth/__projnav" 
IF EXIST "../synth/xst" rmdir /S /Q "../synth/xst" 
IF EXIST "../synth/_ngo" rmdir /S /Q "../synth/_ngo" 

IF EXIST tmp rmdir /S /Q tmp
IF EXIST _xmsgs rmdir /S /Q _xmsgs
IF EXIST vio_sync_out32_xdb rmdir /S /Q vio_sync_out32_xdb
IF EXIST vio_async_in100_xdb rmdir /S /Q vio_async_in100_xdb
IF EXIST vio_async_in192_xdb rmdir /S /Q vio_async_in192_xdb
IF EXIST vio_async_in96_xdb rmdir /S /Q vio_async_in96_xdb
IF EXIST icon4_xdb rmdir /S /Q icon4_xdb

IF EXIST xst rmdir /S /Q xst
IF EXIST xlnx_auto_0_xdb rmdir /S /Q xlnx_auto_0_xdb

IF EXIST coregen.cgp del /F /Q coregen.cgp
IF EXIST coregen.cgc del /F /Q coregen.cgc
IF EXIST coregen.log del /F /Q coregen.log
IF EXIST stdout.log del /F /Q stdout.log
IF EXIST vio_sync_out32.asy del /F /Q vio_sync_out32.asy
IF EXIST vio_sync_out32.cdc del /F /Q vio_sync_out32.cdc
IF EXIST vio_sync_out32.gise del /F /Q vio_sync_out32.gise
IF EXIST vio_sync_out32.ise del /F /Q vio_sync_out32.ise
IF EXIST vio_sync_out32.ncf del /F /Q vio_sync_out32.ncf
IF EXIST vio_sync_out32.ngc del /F /Q vio_sync_out32.ngc
IF EXIST vio_sync_out32.xco del /F /Q vio_sync_out32.xco
IF EXIST vio_sync_out32.xise del /F /Q vio_sync_out32.xise
IF EXIST vio_sync_out32_flist.txt del /F /Q vio_sync_out32_flist.txt
IF EXIST vio_sync_out32_readme.txt del /F /Q vio_sync_out32_readme.txt
IF EXIST vio_sync_out32_xmdf.tcl del /F /Q vio_sync_out32_xmdf.tcl

IF EXIST vio_async_in96.asy del /F /Q vio_async_in96.asy
IF EXIST vio_async_in96.cdc del /F /Q vio_async_in96.cdc
IF EXIST vio_async_in96.gise del /F /Q vio_async_in96.gise
IF EXIST vio_async_in96.ise del /F /Q vio_async_in96.ise
IF EXIST vio_async_in96.ncf del /F /Q vio_async_in96.ncf
IF EXIST vio_async_in96.ngc del /F /Q vio_async_in96.ngc
IF EXIST vio_async_in96.xco del /F /Q vio_async_in96.xco
IF EXIST vio_async_in96.xise del /F /Q vio_async_in96.xise
IF EXIST vio_async_in96_flist.txt del /F /Q vio_async_in96_flist.txt
IF EXIST vio_async_in96_readme.txt del /F /Q vio_async_in96_readme.txt
IF EXIST vio_async_in96_xmdf.tcl del /F /Q vio_async_in96_xmdf.tcl


IF EXIST vio_async_in100.asy del /F /Q vio_async_in100.asy
IF EXIST vio_async_in100.cdc del /F /Q vio_async_in100.cdc
IF EXIST vio_async_in100.gise del /F /Q vio_async_in100.gise
IF EXIST vio_async_in100.ise del /F /Q vio_async_in100.ise
IF EXIST vio_async_in100.ncf del /F /Q vio_async_in100.ncf
IF EXIST vio_async_in100.ngc del /F /Q vio_async_in100.ngc
IF EXIST vio_async_in100.xco del /F /Q vio_async_in100.xco
IF EXIST vio_async_in100.xise del /F /Q vio_async_in100.xise
IF EXIST vio_async_in100_flist.txt del /F /Q vio_async_in100_flist.txt
IF EXIST vio_async_in100_readme.txt del /F /Q vio_async_in100_readme.txt
IF EXIST vio_async_in100_xmdf.tcl del /F /Q vio_async_in100_xmdf.tcl

IF EXIST vio_async_in192.asy del /F /Q vio_async_in192.asy
IF EXIST vio_async_in192.cdc del /F /Q vio_async_in192.cdc
IF EXIST vio_async_in192.gise del /F /Q vio_async_in192.gise
IF EXIST vio_async_in192.ise del /F /Q vio_async_in192.ise
IF EXIST vio_async_in192.ncf del /F /Q vio_async_in192.ncf
IF EXIST vio_async_in192.ngc del /F /Q vio_async_in192.ngc
IF EXIST vio_async_in192.xco del /F /Q vio_async_in192.xco
IF EXIST vio_async_in192.xise del /F /Q vio_async_in192.xise
IF EXIST vio_async_in192_flist.txt del /F /Q vio_async_in192_flist.txt
IF EXIST vio_async_in192_readme.txt del /F /Q vio_async_in192_readme.txt
IF EXIST vio_async_in192_xmdf.tcl del /F /Q vio_async_in192_xmdf.tcl

IF EXIST icon4.gise del /F /Q icon4.gise
IF EXIST icon4.ise del /F /Q icon4.ise
IF EXIST icon4.ncf del /F /Q icon4.ncf
IF EXIST icon4.ngc del /F /Q icon4.ngc
IF EXIST icon4.xco del /F /Q icon4.xco
IF EXIST icon4.xise del /F /Q icon4.xise
IF EXIST icon4_flist.txt del /F /Q icon4_flist.txt
IF EXIST icon4_readme.txt del /F /Q icon4_readme.txt
IF EXIST icon4_xmdf.tcl del /F /Q icon4_xmdf.tcl

IF EXIST ise_flow_results.txt del /F /Q ise_flow_results.txt
IF EXIST DDR2_CORE_vhdl.prj del /F /Q DDR2_CORE_vhdl.prj
IF EXIST mem_interface_top.syr del /F /Q mem_interface_top.syr
IF EXIST DDR2_CORE.ngc del /F /Q DDR2_CORE.ngc
IF EXIST DDR2_CORE.ngo del /F /Q DDR2_CORE.ngo
IF EXIST netlist.lst del /F /Q netlist.lst
IF EXIST DDR2_CORE.ngr del /F /Q DDR2_CORE.ngr
IF EXIST DDR2_CORE_xst.xrpt del /F /Q DDR2_CORE_xst.xrpt
IF EXIST DDR2_CORE.bld del /F /Q DDR2_CORE.bld
IF EXIST DDR2_CORE.ngd del /F /Q DDR2_CORE.ngd
IF EXIST DDR2_CORE_ngdbuild.xrpt del /F /Q  DDR2_CORE_ngdbuild.xrpt
IF EXIST DDR2_CORE_map.map del /F /Q  DDR2_CORE_map.map
IF EXIST DDR2_CORE_map.mrp del /F /Q  DDR2_CORE_map.mrp
IF EXIST DDR2_CORE_map.ngm del /F /Q  DDR2_CORE_map.ngm
IF EXIST DDR2_CORE.pcf del /F /Q  DDR2_CORE.pcf
IF EXIST DDR2_CORE_map.ncd del /F /Q  DDR2_CORE_map.ncd
IF EXIST DDR2_CORE_map.xrpt del /F /Q  DDR2_CORE_map.xrpt
IF EXIST DDR2_CORE_summary.xml del /F /Q  DDR2_CORE_summary.xml
IF EXIST DDR2_CORE_usage.xml del /F /Q  DDR2_CORE_usage.xml
IF EXIST DDR2_CORE.ncd del /F /Q  DDR2_CORE.ncd
IF EXIST DDR2_CORE.par del /F /Q  DDR2_CORE.par
IF EXIST DDR2_CORE.xpi del /F /Q  DDR2_CORE.xpi
IF EXIST smartpreview.twr del /F /Q  smartpreview.twr
IF EXIST DDR2_CORE.ptwx del /F /Q  DDR2_CORE.ptwx
IF EXIST DDR2_CORE.pad del /F /Q  DDR2_CORE.pad
IF EXIST DDR2_CORE.unroutes del /F /Q  DDR2_CORE.unroutes
IF EXIST DDR2_CORE_pad.csv del /F /Q  DDR2_CORE_pad.csv
IF EXIST DDR2_CORE_pad.txt del /F /Q  DDR2_CORE_pad.txt
IF EXIST DDR2_CORE_par.xrpt del /F /Q  DDR2_CORE_par.xrpt
IF EXIST DDR2_CORE.twx del /F /Q  DDR2_CORE.twx
IF EXIST DDR2_CORE.bgn del /F /Q  DDR2_CORE.bgn
IF EXIST DDR2_CORE.twr del /F /Q  DDR2_CORE.twr
IF EXIST DDR2_CORE.drc del /F /Q  DDR2_CORE.drc
IF EXIST DDR2_CORE_bitgen.xwbt del /F /Q  DDR2_CORE_bitgen.xwbt
IF EXIST DDR2_CORE.bit del DDR2_CORE.bit

:: Files and folders generated by create ise
IF EXIST test_xdb rmdir /S /Q test_xdb 
IF EXIST _xmsgs rmdir /S /Q _xmsgs 
IF EXIST test.gise del /F /Q test.gise
IF EXIST test.xise del /F /Q test.xise
IF EXIST test.xise del /F /Q test.xise

:: Files generated by ISE through GUI mode
IF EXIST _ngo rmdir /S /Q _ngo 
IF EXIST xst rmdir /S /Q xst 
IF EXIST DDR2_CORE.lso del /F /Q DDR2_CORE.lso
IF EXIST DDR2_CORE.prj del /F /Q DDR2_CORE.prj
IF EXIST DDR2_CORE.xst del /F /Q DDR2_CORE.xst
IF EXIST DDR2_CORE.stx del /F /Q DDR2_CORE.stx
IF EXIST DDR2_CORE.syr del /F /Q DDR2_CORE.syr
IF EXIST DDR2_CORE_prev_built.ngd del /F /Q DDR2_CORE_prev_built.ngd
IF EXIST test.ntrc_log del /F /Q test.ntrc_log
IF EXIST DDR2_CORE_guide.ncd del /F /Q DDR2_CORE_guide.ncd
IF EXIST DDR2_CORE.ut del /F /Q DDR2_CORE.ut
IF EXIST DDR2_CORE.cmd_log del /F /Q DDR2_CORE.cmd_log
IF EXIST par_usage_statistics.html del /F /Q par_usage_statistics.html
IF EXIST usage_statistics_webtalk.html del /F /Q usage_statistics_webtalk.html
IF EXIST webtalk.log del /F /Q webtalk.log
IF EXIST device_usage_statistics.html del /F /Q device_usage_statistics.html
IF EXIST DDR2_CORE_summary.html del /F /Q DDR2_CORE_summary.html

@echo on
