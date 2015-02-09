# The package naming convention is <core_name>_xmdf
package provide DDR2_CORE_xmdf 1.0

# This includes some utilities that support common XMDF operations 
package require utilities_xmdf

# Define a namespace for this package. The name of the name space
# is <core_name>_xmdf
namespace eval ::DDR2_CORE_xmdf {
# Use this to define any statics
}

# Function called by client to rebuild the params and port arrays
# Optional when the use context does not require the param or ports
# arrays to be available.
proc ::DDR2_CORE_xmdf::xmdfInit { instance } {
	# Variable containing name of library into which module is compiled
	# Recommendation: <module_name>
	# Required
	utilities_xmdf::xmdfSetData $instance Module Attributes Name DDR2_CORE
}
# ::DDR2_CORE_xmdf::xmdfInit

# Function called by client to fill in all the xmdf* data variables
# based on the current settings of the parameters
proc ::DDR2_CORE_xmdf::xmdfApplyParams { instance } {

set fcount 0
	# Array containing libraries that are assumed to exist
	# Examples include unisim and xilinxcorelib
	# Optional
	# In this example, we assume that the unisim library will
	# be magically
	# available to the simulation and synthesis tool
	utilities_xmdf::xmdfSetData $instance FileSet $fcount type logical_library
	utilities_xmdf::xmdfSetData $instance FileSet $fcount logical_library unisim
	incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/ddr2_chipscope.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/DDR2_CORE.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/ddr2_ctrl.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/ddr2_idelay_ctrl.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/ddr2_infrastructure.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/ddr2_mem_if_top.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/ddr2_phy_calib.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/ddr2_phy_ctl_io.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/ddr2_phy_dm_iob.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/ddr2_phy_dq_iob.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/ddr2_phy_dqs_iob.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/ddr2_phy_init.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/ddr2_phy_io.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/ddr2_phy_top.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/ddr2_phy_write.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/ddr2_top.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/ddr2_usr_addr_fifo.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/ddr2_usr_rd.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/ddr2_usr_top.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/rtl/ddr2_usr_wr.vhd
utilities_xmdf::xmdfSetData $instance FileSet $fcount type vhdl
incr fcount

utilities_xmdf::xmdfSetData $instance FileSet $fcount relative_path DDR2_CORE/user_design/par/DDR2_CORE.ucf
utilities_xmdf::xmdfSetData $instance FileSet $fcount type ucf 
utilities_xmdf::xmdfSetData $instance FileSet $fcount associated_module DDR2_CORE
incr fcount

}

# ::gen_comp_name_xmdf::xmdfApplyParams
