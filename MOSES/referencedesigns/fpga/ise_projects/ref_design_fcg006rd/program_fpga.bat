echo off

set proj_dir=.
set bsdl_dir=..\..\bsdl
set proj_name=ref_design
set proj_file=%proj_dir%\%proj_name%.bit

echo ====================================
echo Creating temporary impact batch
echo ====================================
echo setMode -bscan > temp.txt
echo setCable -p usb21 >> temp.txt
echo addDevice -p 1 -file %proj_file% >> temp.txt
echo addDevice -p 2 -file %bsdl_dir%\PCI9056BA.bsd >> temp.txt
echo addDevice -p 3 -file %bsdl_dir%\DP83849IVS.bsd >> temp.txt
echo program -p 1 -v >> temp.txt
rem removed -v; because block ram bitstream doesn't have a .msk file
echo quit >> temp.txt
echo ====================================
echo Executing impact batch
echo ====================================
%XILINX%\bin\nt\impact -batch temp.txt
pause