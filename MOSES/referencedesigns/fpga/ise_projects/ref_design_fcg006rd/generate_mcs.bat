echo off

set proj_name=ref_design
set brd_name=fcg006rd
set mcs_file=%proj_name%_%brd_name%

echo ====================================
echo Creating temporary impact batch
echo ====================================
echo setMode -pff 														> temp.txt
echo setSubmode -pffparallel 											>> temp.txt
echo addPromDevice -p 1 -size 2048 -name 16M 							>> temp.txt
echo addDesign -version 0 -name 0 										>> temp.txt
echo addDeviceChain -index 0 											>> temp.txt
echo addDevice -p 1 -file .\%proj_name%.bit 							>> temp.txt
echo generate -output %mcs_file%.mcs -format mcs -fillvalue FF -spi		>> temp.txt
echo quit 																>> temp.txt
echo ====================================
echo Executing impact batch
echo ====================================
%XILINX%\bin\nt\impact -batch temp.txt