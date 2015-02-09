vlib work
puts "==========================================="
puts "Common Modules"
puts "==========================================="
vcom -explicit  -93 "../common/ctiUtil.vhd"
vcom -explicit  -93 "../common/ctiSim.vhd"
vcom -explicit  -93 "../common/txt_util.vhd"
vcom -explicit  -93 "../common/xto1mux_32.vhd"
vcom -explicit  -93 "../common/regBank_32.vhd"

puts "==========================================="
puts "SPI Modules"
puts "==========================================="
vcom -explicit  -93 "../spiFlash32/mem_util_pkg.vhd"
vcom -explicit  -93 "../spiFlash32/M25P16_Internal_Logic.vhd"
vcom -explicit  -93 "../spiFlash32/M25P16_Memory_Access.vhd"
vcom -explicit  -93 "../spiFlash32/M25P16_ACDC_check.vhd"
vcom -explicit  -93 "../spiFlash32/M25P16.vhd"
vcom -explicit  -93 "../spiFlash32/kcpsm3.vhd"
vcom -explicit  -93 ../spiFlash32/spi_module_cti.vhd
vcom -explicit  -93 ../spiFlash32/PBPROGF2.VHD
vcom -explicit  -93 ../spiFlash32/ctiSPIf2.vhd

puts "==========================================="
puts "Clock Modules"
puts "==========================================="
vcom -explicit  -93 "../v5clock/plldiv_mod.vhd"
vcom -explicit  -93 "../v5clock/clkfwd_mod.vhd"
vcom -explicit  -93 "../v5clock/clkControl.vhd"
vcom -explicit  -93 "../v5clock/clkControlMem.vhd"

puts "==========================================="
puts "Coregen Memory Modules"
puts "==========================================="
vcom -explicit  -93 "../v5coregen/gen200mhz.vhd"
vcom -explicit  -93 "../v5coregen/blockRAM.vhd"
vcom -explicit  -93 "../v5coregen/dpRAM32_8.vhd"
vcom "../v5coregen/fifo_42x16.vhd"
vcom "../v5coregen/dp_32_64.vhd"
vcom  ../v5coregen/dp_a256x8_b256x8.vhd

vcom -explicit  -93 "../v5config/v5InternalConfig.vhd"

puts "==========================================="
puts "PLX interface modules"
puts "==========================================="
vcom -explicit  -93 "../plxControl/plxArb.vhd"
vcom -explicit  -93 "../plxControl/plxCfgRom.vhd"
vcom -explicit  -93 "../plxControl/plx32BitSlave.vhd"
vcom -explicit  -93 "../plxControl/plx32BitMaster.vhd"
vcom -explicit  -93 "../plxControl/plxBusMonitor.vhd"
vcom -explicit  -93 "../plxControl/plxDoutMux.vhd"

puts "==========================================="
puts "Serial Modules"
puts "==========================================="
vcom -explicit  -93 "../serial/bbfifo_16x8.vhd"
vcom -explicit  -93 "../serial/uart_tx_plus.vhd"
vcom -explicit  -93 "../serial/uart_rx.vhd"
vcom -explicit  -93 "../serial/kcuart_tx.vhd"
vcom -explicit  -93 "../serial/kcuart_rx.vhd"
vcom -explicit  -93 "../serial/serialTest.vhd"

puts "==========================================="
puts "Coregen TEMAC Modules"
puts "==========================================="
vcom  ../v5coregen/v5_emac_v1_3/example_design/client/address_swap_module_8.vhd
vcom  ../v5coregen/v5_emac_v1_3/example_design/client/fifo/tx_client_fifo_8.vhd
vcom  ../v5coregen/v5_emac_v1_3/example_design/client/fifo/rx_client_fifo_8.vhd
vcom  ../v5coregen/v5_emac_v1_3/example_design/client/fifo/eth_fifo_8.vhd
vcom  ../v5coregen/v5_emac_v1_3/example_design/physical/mii_if.vhd
vcom  ../v5coregen/v5_emac_v1_3/example_design/v5_emac_v1_3.vhd
vcom  ../v5coregen/v5_emac_v1_3/example_design/v5_emac_v1_3_block.vhd
vcom  ../v5coregen/v5_emac_v1_3/example_design/v5_emac_v1_3_locallink.vhd
vcom  ../v5coregen/v5_emac_v1_3/example_design/v5_emac_v1_3_example_design.vhd

puts "==========================================="
puts "EMAC Modules"
puts "==========================================="
vcom  ../emac/emac_init.vhd
#vcom  ../emac/kcpsm3.vhd should already be compiled
vcom  ../emac/ICMPPROG.vhd
vcom  ../emac/emacICMP.vhd
vcom  ../emac/emac_init.vhd
vcom  ../emac/emacRx.vhd
vcom  ../emac/emacTx.vhd

puts "==========================================="
puts "MIG Modules"
puts "==========================================="
vcom "../v5coregen/mig20/user_design/rtl/mig20_phy_dqs_iob.vhd"
vcom "../v5coregen/mig20/user_design/rtl/mig20_phy_dq_iob.vhd"
vcom "../v5coregen/mig20/user_design/rtl/mig20_phy_dm_iob.vhd"
vcom "../v5coregen/mig20/user_design/rtl/mig20_phy_calib_0.vhd"
vcom "../v5coregen/mig20/user_design/rtl/mig20_usr_wr_0.vhd"
vcom "../v5coregen/mig20/user_design/rtl/mig20_usr_rd_0.vhd"
vcom "../v5coregen/mig20/user_design/rtl/mig20_usr_addr_fifo_0.vhd"
vcom "../v5coregen/mig20/user_design/rtl/mig20_phy_write_0.vhd"
vcom "../v5coregen/mig20/user_design/rtl/mig20_phy_io_0.vhd"
vcom "../v5coregen/mig20/user_design/rtl/mig20_phy_init_0.vhd"
vcom "../v5coregen/mig20/user_design/rtl/mig20_phy_ctl_io_0.vhd"
vcom "../v5coregen/mig20/user_design/rtl/mig20_usr_top_0.vhd"
vcom "../v5coregen/mig20/user_design/rtl/mig20_phy_top_0.vhd"
vcom "../v5coregen/mig20/user_design/rtl/mig20_ctrl_0.vhd"
vcom "../v5coregen/mig20/user_design/rtl/mig20_mem_if_top_0.vhd"
vcom "../v5coregen/mig20/user_design/rtl/mig20_infrastructure.vhd"
vcom "../v5coregen/mig20/user_design/rtl/mig20_idelay_ctrl.vhd"
vcom "../v5coregen/mig20/user_design/rtl/mig20_ddr2_top_0.vhd"
vcom "../v5coregen/mig20/user_design/rtl/mig20_app.vhd"

# DDR2 application interface
vcom "../v5coregen/mig20/user_design/rtl/ddr2_interface.vhd"

puts "==========================================="
puts "Memory model - not supported by ModelSimXE"
puts "==========================================="
# Memory model
#vcom "../v5coregen/mig20/user_design/sim/wiredly.vhd"
#vlog  "../v5coregen/mig20/user_design/sim/glbl.v"
#vlog  +incdir+. +define+x512Mb +define+sg3 +define+x16 "../v5coregen/mig20/user_design/sim/ddr2_model.v"

puts "==========================================="
puts "GTP modules"
puts "==========================================="
#vcom -explicit  -93 ../rocketio/dpa64x8_b16x32_mod.vhd
vcom -explicit  -93  ../rocketio/pciegtp_wrapper_tile.vhd
vcom -explicit  -93  ../rocketio/pciegtp_wrapper.vhd
vcom -explicit  -93 ../rocketio/gtp_frame_tx.vhd
vcom -explicit  -93 ../rocketio/gtp_frame_rx.vhd

vcom -explicit  -93 ../v5coregen/pciegtx_wrapper/src/mgt_usrclk_source_pll.vhd
vcom -explicit  -93 ../v5coregen/pciegtx_wrapper/src/pciegtx_wrapper.vhd
vcom -explicit  -93 ../v5coregen/pciegtx_wrapper/src/pciegtx_wrapper_tile.vhd
   
vcom -explicit  -93 ../rocketio/mgt_tester.vhd

puts "==========================================="
puts "Top level"
puts "==========================================="
vcom -explicit  -93 ../topRefDesign/ref_design_fcg001rd_pkg.vhd
vcom -explicit  -93 "../topRefDesign/ref_design.vhd"

puts "==========================================="
puts "Test bench"
puts "==========================================="
vcom -explicit  -93 "init_tb.vhd"
