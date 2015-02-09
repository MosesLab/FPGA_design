onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group {Clk Control}
add wave -noupdate -group {Clk Control} -format Logic /init_tb/uut/u_clkcontrol/mainclkp
add wave -noupdate -group {Clk Control} -format Logic /init_tb/uut/u_clkcontrol/mainclkn
add wave -noupdate -group {Clk Control} -format Logic /init_tb/uut/u_clkcontrol/clk50
add wave -noupdate -group {Clk Control} -format Logic /init_tb/uut/u_clkcontrol/clk100
add wave -noupdate -group {Clk Control} -format Logic /init_tb/uut/u_clkcontrol/clk200
add wave -noupdate -group {Clk Control} -format Logic /init_tb/uut/u_clkcontrol/lclkfb
add wave -noupdate -group {Clk Control} -format Literal /init_tb/uut/u_clkcontrol/lclko
add wave -noupdate -divider {Local bus}
add wave -noupdate -format Logic /init_tb/uut/clk50
add wave -noupdate -format Logic /init_tb/lb_lclko
add wave -noupdate -format Logic /init_tb/lb_lclki
add wave -noupdate -format Logic /init_tb/lb_lresetn
add wave -noupdate -format Logic /init_tb/lb_lhold
add wave -noupdate -format Logic /init_tb/lb_lholda
add wave -noupdate -format Logic /init_tb/lb_ccsn
add wave -noupdate -format Logic /init_tb/lb_adsn
add wave -noupdate -format Literal -radix hexadecimal /init_tb/lb_la_32
add wave -noupdate -format Literal -radix hexadecimal /init_tb/lb_lben
add wave -noupdate -format Literal -radix hexadecimal /init_tb/lb_ld
add wave -noupdate -format Logic /init_tb/lb_lw_rn
add wave -noupdate -format Logic /init_tb/lb_readyn
add wave -noupdate -format Logic /init_tb/lb_blastn
add wave -noupdate -format Logic /init_tb/lb_breqo
add wave -noupdate -format Logic /init_tb/lb_lserrn
add wave -noupdate -group {PLX other}
add wave -noupdate -group {PLX other} -format Literal /init_tb/lb_la
add wave -noupdate -group {PLX other} -format Logic /init_tb/lb_bigendn
add wave -noupdate -group {PLX other} -format Logic /init_tb/lb_breqi
add wave -noupdate -group {PLX other} -format Logic /init_tb/lb_btermn
add wave -noupdate -group {PLX other} -format Logic /init_tb/lb_ccsn
add wave -noupdate -group {PLX other} -format Literal /init_tb/lb_dackn
add wave -noupdate -group {PLX other} -format Literal /init_tb/lb_dp
add wave -noupdate -group {PLX other} -format Literal /init_tb/lb_dreqn
add wave -noupdate -group {PLX other} -format Logic /init_tb/lb_eotn
add wave -noupdate -group {PLX other} -format Logic /init_tb/lb_lintin
add wave -noupdate -group {PLX other} -format Logic /init_tb/lb_linton
add wave -noupdate -group {PLX other} -format Logic /init_tb/lb_pmereon
add wave -noupdate -group {PLX other} -format Logic /init_tb/lb_useri
add wave -noupdate -group {PLX other} -format Logic /init_tb/lb_usero
add wave -noupdate -group {PLX other} -format Logic /init_tb/lb_waitn
add wave -noupdate -format Logic /init_tb/plx_hostenn
add wave -noupdate -format Logic /init_tb/simfinished
add wave -noupdate -format Literal -radix hexadecimal /init_tb/user_led
add wave -noupdate -divider {tb data}
add wave -noupdate -format Literal -radix hexadecimal /init_tb/uut/g_ddr2n/u_dp/u0/memory_i(0)
add wave -noupdate -format Literal -radix hexadecimal /init_tb/uut/g_ddr2n/u_dp/u0/memory_i(1)
add wave -noupdate -format Literal -radix hexadecimal /init_tb/uut/g_ddr2n/u_dp/u0/memory_i(2)
add wave -noupdate -format Literal -radix hexadecimal /init_tb/uut/g_ddr2n/u_dp/u0/memory_i(3)
add wave -noupdate -format Literal -radix hexadecimal /init_tb/uut/g_ddr2n/u_dp/u0/memory_i(4)
add wave -noupdate -format Literal -radix hexadecimal /init_tb/uut/g_ddr2n/u_dp/u0/memory_i(5)
add wave -noupdate -format Literal -radix hexadecimal /init_tb/uut/g_ddr2n/u_dp/u0/memory_i(6)
add wave -noupdate -format Literal -radix hexadecimal /init_tb/uut/g_ddr2n/u_dp/u0/memory_i(7)
add wave -noupdate -format Literal -radix hexadecimal /init_tb/uut/g_ddr2n/u_dp/u0/memory_i(8)
add wave -noupdate -format Literal -radix hexadecimal /init_tb/uut/g_ddr2n/u_dp/u0/memory_i(9)
add wave -noupdate -format Literal -radix hexadecimal /init_tb/uut/g_ddr2n/u_dp/u0/memory_i
add wave -noupdate -divider {FPGA Data path}
add wave -noupdate -format Literal -radix hexadecimal /init_tb/uut/ld_out
add wave -noupdate -format Logic -radix hexadecimal /init_tb/uut/dm_ld_dir
add wave -noupdate -format Logic -radix hexadecimal /init_tb/uut/ds_ld_dir
add wave -noupdate -divider {PLX Arbitration}
add wave -noupdate -format Literal /init_tb/uut/u_plxarb/curstate
add wave -noupdate -divider {PLX Master (dm)}
add wave -noupdate -format Literal /init_tb/uut/u_plx32bitmaster/cfgromptrcur
add wave -noupdate -format Literal /init_tb/uut/u_plx32bitmaster/cfgromptr
add wave -noupdate -format Literal /init_tb/uut/u_plx32bitmaster/cfgromdout
add wave -noupdate -format Logic /init_tb/uut/u_plx32bitmaster/cfgpending
add wave -noupdate -format Logic /init_tb/uut/u_plx32bitmaster/cfgcomplete
add wave -noupdate -group {Master Ctrl}
add wave -noupdate -group {Master Ctrl} -format Logic /init_tb/uut/u_plx32bitmaster/backoff
add wave -noupdate -group {Master Ctrl} -format Literal /init_tb/uut/u_plx32bitmaster/ctrlstate
add wave -noupdate -group {Master Ctrl} -format Literal /init_tb/uut/u_plx32bitmaster/ctrlnextstate
add wave -noupdate -group {Master Ctrl} -format Logic /init_tb/uut/u_plx32bitmaster/req
add wave -noupdate -group {Master Ctrl} -format Logic /init_tb/uut/u_plx32bitmaster/ack
add wave -noupdate -group {Master Ctrl} -format Logic /init_tb/uut/u_plx32bitmaster/op
add wave -noupdate -group {Master Ctrl} -format Logic /init_tb/uut/u_plx32bitmaster/curaddrload
add wave -noupdate -group {Master Ctrl} -format Logic /init_tb/uut/u_plx32bitmaster/curaddrinc
add wave -noupdate -group {Master Ctrl} -format Literal -radix hexadecimal /init_tb/uut/u_plx32bitmaster/curaddr
add wave -noupdate -group {Master Ctrl} -format Literal -radix hexadecimal /init_tb/uut/u_plx32bitmaster/nextaddr
add wave -noupdate -group {Master Ctrl} -format Literal -radix hexadecimal /init_tb/uut/u_plx32bitmaster/ramwr
add wave -noupdate -group {Master Ctrl} -format Literal -radix hexadecimal /init_tb/uut/u_plx32bitmaster/ramaddr
add wave -noupdate -group {Master Ctrl} -format Literal -radix hexadecimal /init_tb/uut/u_plx32bitmaster/ramrdaddr
add wave -noupdate -group {Master Ctrl} -format Literal -radix hexadecimal /init_tb/uut/u_plx32bitmaster/ramwraddr
add wave -noupdate -group {Master Ctrl} -format Logic /init_tb/uut/u_plx32bitmaster/burstcntrst
add wave -noupdate -group {Master Ctrl} -format Logic /init_tb/uut/u_plx32bitmaster/burstcnten
add wave -noupdate -group {Master Ctrl} -format Literal -radix hexadecimal /init_tb/uut/u_plx32bitmaster/burstcnt
add wave -noupdate -divider {PLX Slave (ds)}
add wave -noupdate -expand -group {Slave Ctrl}
add wave -noupdate -group {Slave Ctrl} -format Literal /init_tb/uut/u_plx32bitslave/ctrlstate
add wave -noupdate -group {Slave Ctrl} -format Logic /init_tb/uut/u_plx32bitslave/addrvalid0
add wave -noupdate -group {Slave Ctrl} -format Logic /init_tb/uut/u_plx32bitslave/burstcnten
add wave -noupdate -group {Slave Ctrl} -format Logic /init_tb/uut/u_plx32bitslave/burstcntrst
add wave -noupdate -group {Slave Ctrl} -format Literal -radix hexadecimal /init_tb/uut/u_plx32bitslave/burstcnt
add wave -noupdate -format Logic /init_tb/uut/ds0addrvalid
add wave -noupdate -format Literal /init_tb/uut/ds0wrbyte
add wave -noupdate -format Literal -radix decimal /init_tb/uut/ds0ramaddr
add wave -noupdate -format Logic /init_tb/uut/ds0ramen
add wave -noupdate -format Literal -radix hexadecimal /init_tb/uut/ds0ramwr
add wave -noupdate -format Literal -radix hexadecimal /init_tb/uut/ds0regdout
add wave -noupdate -format Logic /init_tb/uut/ds0regen
add wave -noupdate -format Literal -radix hexadecimal /init_tb/uut/ds0reglocalout
add wave -noupdate -format Literal -radix hexadecimal /init_tb/uut/ds0regsel
add wave -noupdate -format Literal -radix hexadecimal /init_tb/uut/ds0regwr
add wave -noupdate -divider GPIO
add wave -noupdate -format Literal -radix hexadecimal /init_tb/gpio_n
add wave -noupdate -format Literal -radix hexadecimal /init_tb/gpio_p
add wave -noupdate -format Literal -radix hexadecimal /init_tb/hss_user_io
add wave -noupdate -divider {Not implemented}
add wave -noupdate -group DDR2
add wave -noupdate -group DDR2 -format Literal /init_tb/ddr2_a
add wave -noupdate -group DDR2 -format Literal /init_tb/ddr2_ba
add wave -noupdate -group DDR2 -format Logic /init_tb/ddr2_cas_n
add wave -noupdate -group DDR2 -format Literal /init_tb/ddr2_ck
add wave -noupdate -group DDR2 -format Literal /init_tb/ddr2_ck_n
add wave -noupdate -group DDR2 -format Literal /init_tb/ddr2_cke
add wave -noupdate -group DDR2 -format Literal /init_tb/ddr2_cs_n
add wave -noupdate -group DDR2 -format Literal /init_tb/ddr2_dm
add wave -noupdate -group DDR2 -format Literal /init_tb/ddr2_dq
add wave -noupdate -group DDR2 -format Literal /init_tb/ddr2_dqs
add wave -noupdate -group DDR2 -format Literal /init_tb/ddr2_dqs_n
add wave -noupdate -group DDR2 -format Literal /init_tb/ddr2_odt
add wave -noupdate -group DDR2 -format Logic /init_tb/ddr2_ras_n
add wave -noupdate -group DDR2 -format Logic /init_tb/ddr2_we_n
add wave -noupdate -group EEPROM
add wave -noupdate -group EEPROM -format Logic /init_tb/eth_ee_clk
add wave -noupdate -group EEPROM -format Logic /init_tb/eth_ee_cs
add wave -noupdate -group EEPROM -format Logic /init_tb/eth_ee_dido
add wave -noupdate -group MII
add wave -noupdate -group MII -format Logic /init_tb/mii_clk
add wave -noupdate -group MII -format Logic /init_tb/mii_mdc
add wave -noupdate -group MII -format Logic /init_tb/mii_mdio
add wave -noupdate -group MII -format Logic /init_tb/mii_resetn
add wave -noupdate -group MII -format Logic /init_tb/miia_col
add wave -noupdate -group MII -format Logic /init_tb/miia_crs
add wave -noupdate -group MII -format Logic /init_tb/miia_intn
add wave -noupdate -group MII -format Logic /init_tb/miia_rxclk
add wave -noupdate -group MII -format Literal /init_tb/miia_rxd
add wave -noupdate -group MII -format Logic /init_tb/miia_rxdv
add wave -noupdate -group MII -format Logic /init_tb/miia_rxer
add wave -noupdate -group MII -format Logic /init_tb/miia_txclk
add wave -noupdate -group MII -format Literal /init_tb/miia_txd
add wave -noupdate -group MII -format Logic /init_tb/miia_txen
add wave -noupdate -group MII -format Logic /init_tb/miib_col
add wave -noupdate -group MII -format Logic /init_tb/miib_crs
add wave -noupdate -group MII -format Logic /init_tb/miib_intn
add wave -noupdate -group MII -format Logic /init_tb/miib_rxclk
add wave -noupdate -group MII -format Literal /init_tb/miib_rxd
add wave -noupdate -group MII -format Logic /init_tb/miib_rxdv
add wave -noupdate -group MII -format Logic /init_tb/miib_rxer
add wave -noupdate -group MII -format Logic /init_tb/miib_txclk
add wave -noupdate -group MII -format Literal /init_tb/miib_txd
add wave -noupdate -group MII -format Logic /init_tb/miib_txen
add wave -noupdate -group RS485
add wave -noupdate -group RS485 -format Logic /init_tb/rs0_renn
add wave -noupdate -group RS485 -format Logic /init_tb/rs0_rx
add wave -noupdate -group RS485 -format Logic /init_tb/rs0_ten
add wave -noupdate -group RS485 -format Logic /init_tb/rs0_tx
add wave -noupdate -group RS485 -format Logic /init_tb/rs1_renn
add wave -noupdate -group RS485 -format Logic /init_tb/rs1_rx
add wave -noupdate -group RS485 -format Logic /init_tb/rs1_ten
add wave -noupdate -group RS485 -format Logic /init_tb/rs1_tx
add wave -noupdate -group SPI
add wave -noupdate -group SPI -format Logic /init_tb/spia_csn
add wave -noupdate -group SPI -format Logic /init_tb/spia_mosi
add wave -noupdate -group SPI -format Logic /init_tb/spib_clk
add wave -noupdate -group SPI -format Logic /init_tb/spib_csn
add wave -noupdate -group SPI -format Logic /init_tb/spib_miso
add wave -noupdate -group SPI -format Logic /init_tb/spib_mosi
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4146400 ps} 0}
configure wave -namecolwidth 322
configure wave -valuecolwidth 159
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {3890473 ps} {4402327 ps}
