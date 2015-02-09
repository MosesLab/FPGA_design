call rem_files.bat

::Following coregen commands to be uncommented  when the parameter DEBUG_EN is changed from 0 to 1 in DDR2_CORE_JAH.v/.vhd file.
::coregen -b makeproj.bat
::coregen -p . -b icon4_cg.xco
::coregen -p . -b vio_async_in96_cg.xco
::coregen -p . -b vio_async_in192_cg.xco
::coregen -p . -b vio_sync_out32_cg.xco
::coregen -p . -b vio_async_in100_cg.xco

::del *.ncf
echo Synthesis Tool: XST

mkdir "../synth/__projnav" > ise_flow_results.txt
mkdir "../synth/xst" >> ise_flow_results.txt
mkdir "../synth/xst/work" >> ise_flow_results.txt

xst -ifn xst_run.txt -ofn mem_interface_top.syr -intstyle ise >> ise_flow_results.txt
ngdbuild -intstyle ise -dd ../synth/_ngo -nt timestamp -uc DDR2_CORE_JAH.ucf -p xc5vlx50tff665-1 DDR2_CORE_JAH.ngc DDR2_CORE_JAH.ngd >> ise_flow_results.txt

map -intstyle ise -detail -w -logic_opt off -ol high -xe n -t 1 -cm area -o DDR2_CORE_JAH_map.ncd DDR2_CORE_JAH.ngd DDR2_CORE_JAH.pcf >> ise_flow_results.txt
par -w -intstyle ise -ol high -xe n DDR2_CORE_JAH_map.ncd DDR2_CORE_JAH.ncd DDR2_CORE_JAH.pcf >> ise_flow_results.txt
trce -e 3 -xml DDR2_CORE_JAH DDR2_CORE_JAH.ncd -o DDR2_CORE_JAH.twr DDR2_CORE_JAH.pcf >> ise_flow_results.txt
bitgen -intstyle ise -f mem_interface_top.ut DDR2_CORE_JAH.ncd >> ise_flow_results.txt

echo done!
