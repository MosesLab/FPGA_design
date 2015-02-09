
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name MOSES_FPGA_Design -dir "D:/MOSES/MOSES_Design/MOSES_FPGA_Design/planAhead_run_1" -part xc5vlx50tff665-1
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "D:/MOSES/MOSES_Design/MOSES_FPGA_Design/MOSES_FPGA_Design.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {D:/MOSES/MOSES_Design/MOSES_FPGA_Design} {ipcore_dir} }
add_files [list {ipcore_dir/Camera_Interface_ICON.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/Camera_Interface_ILA.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/DDR2_DataManager_ILA.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/DDR2_ILA.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/DDR2_INTERFACE_ILA.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "ffpci104_fcg006rd.ucf" [current_fileset -constrset]
add_files [list {ffpci104_fcg006rd.ucf}] -fileset [get_property constrset [current_run]]
link_design
