onerror {resume}
quietly WaveActivateNextPane {} 0
quietly virtual signal -install /example_tb/example_mgt_top_i/g_txrx__0/u_tx {/example_tb/example_mgt_top_i/g_txrx__0/u_tx/tx_data  } tx_data_08
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /example_tb/reset_i
add wave -noupdate -format Logic /example_tb/connect
add wave -noupdate -format Logic /example_tb/tile0_plllkdet_i
add wave -noupdate -format Logic /example_tb/tile1_plllkdet_i
add wave -noupdate -format Literal /example_tb/example_mgt_top_i/lb_a
add wave -noupdate -format Logic /example_tb/example_mgt_top_i/lb_clk
add wave -noupdate -format Literal /example_tb/example_mgt_top_i/lb_di
add wave -noupdate -format Literal /example_tb/example_mgt_top_i/lb_do
add wave -noupdate -format Logic /example_tb/example_mgt_top_i/lb_en
add wave -noupdate -format Literal /example_tb/example_mgt_top_i/lb_loopback
add wave -noupdate -format Literal /example_tb/example_mgt_top_i/lb_rx_done
add wave -noupdate -format Literal /example_tb/example_mgt_top_i/lb_rx_err_cnt
add wave -noupdate -format Literal /example_tb/example_mgt_top_i/lb_rx_ok
add wave -noupdate -format Literal /example_tb/example_mgt_top_i/lb_rx_sz
add wave -noupdate -format Literal /example_tb/example_mgt_top_i/lb_tx_done
add wave -noupdate -format Literal /example_tb/example_mgt_top_i/lb_tx_start
add wave -noupdate -format Literal /example_tb/example_mgt_top_i/lb_tx_sz
add wave -noupdate -format Literal /example_tb/example_mgt_top_i/rx_do
add wave -noupdate -format Literal /example_tb/example_mgt_top_i/rx_en
add wave -noupdate -format Literal /example_tb/example_mgt_top_i/tx_do
add wave -noupdate -format Literal /example_tb/example_mgt_top_i/lb_we
add wave -noupdate -format Literal /example_tb/example_mgt_top_i/tx_en
add wave -noupdate -divider <NULL>
add wave -noupdate -expand -group GTP0_frame_tx
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/user_clk
add wave -noupdate -group GTP0_frame_tx -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/g_txrx__0/u_tx/tx_data_08
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/tx_last
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/tx_last_r
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/tx_last_r2
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/tx_last_r3
add wave -noupdate -group GTP0_frame_tx -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/g_txrx__0/u_tx/tx_data
add wave -noupdate -group GTP0_frame_tx -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/g_txrx__0/u_tx/doa
add wave -noupdate -group GTP0_frame_tx -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/g_txrx__0/u_tx/rd_cnt
add wave -noupdate -group GTP0_frame_tx -format Literal /example_tb/example_mgt_top_i/g_txrx__0/u_tx/tx_charisk
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/done_r
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/done_r2
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/lb_done
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/lb_start
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/start_r
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/start_r2
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/start_r3
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/start_r4
add wave -noupdate -group GTP0_frame_tx -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/g_txrx__0/u_tx/lb_sz
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/user_clk
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/tx_last
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/tx_last_r
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/tx_last_r2
add wave -noupdate -group GTP0_frame_tx -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/g_txrx__0/u_tx/rd_cnt
add wave -noupdate -group GTP0_frame_tx -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/g_txrx__0/u_tx/doa
add wave -noupdate -group GTP0_frame_tx -format Literal /example_tb/example_mgt_top_i/g_txrx__0/u_tx/tx_data_r
add wave -noupdate -group GTP0_frame_tx -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/g_txrx__0/u_tx/tx_data
add wave -noupdate -group GTP0_frame_tx -format Literal /example_tb/example_mgt_top_i/g_txrx__0/u_tx/tx_charisk
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/done_r
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/done_r2
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/lb_done
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/lb_start
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/start_r
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/start_r2
add wave -noupdate -group GTP0_frame_tx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_tx/start_r3
add wave -noupdate -group GTP0_frame_tx -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/g_txrx__0/u_tx/lb_sz
add wave -noupdate -group GTP0_frame_rx
add wave -noupdate -group GTP0_frame_rx -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/g_txrx__0/u_rx/rx_data
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/valid_data
add wave -noupdate -group GTP0_frame_rx -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/g_txrx__0/u_rx/wr_cnt
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/comma_detected
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/start_detected
add wave -noupdate -group GTP0_frame_rx -format Literal /example_tb/example_mgt_top_i/g_txrx__0/u_rx/state
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/done
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/done_r
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/lb_rx_ok
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/lb_rx_ok_r
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/lb_rx_ok_r2
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/lb_done
add wave -noupdate -group GTP0_frame_rx -format Literal /example_tb/example_mgt_top_i/g_txrx__0/u_rx/lb_sz
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/reset_on_error
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/system_reset
add wave -noupdate -group GTP0_frame_rx -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/g_txrx__0/u_rx/c_comma_char
add wave -noupdate -group GTP0_frame_rx -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/g_txrx__0/u_rx/c_start_char
add wave -noupdate -group GTP0_frame_rx -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/g_txrx__0/u_rx/rx_data
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/valid_data
add wave -noupdate -group GTP0_frame_rx -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/g_txrx__0/u_rx/wr_cnt
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/comma_detected
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/start_detected
add wave -noupdate -group GTP0_frame_rx -format Literal /example_tb/example_mgt_top_i/g_txrx__0/u_rx/state
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/done
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/done_r
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/lb_rx_ok
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/lb_rx_ok_r
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/lb_rx_ok_r2
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/lb_done
add wave -noupdate -group GTP0_frame_rx -format Literal /example_tb/example_mgt_top_i/g_txrx__0/u_rx/lb_sz
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/reset_on_error
add wave -noupdate -group GTP0_frame_rx -format Logic /example_tb/example_mgt_top_i/g_txrx__0/u_rx/system_reset
add wave -noupdate -group GTP0_frame_rx -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/g_txrx__0/u_rx/c_comma_char
add wave -noupdate -group GTP0_frame_rx -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/g_txrx__0/u_rx/c_start_char
add wave -noupdate -divider TILE0_PCIEGTP_WRAPPER
add wave -noupdate -group {T0 - Share Tile and PLL}
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/clkin_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/gtpreset_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/plllkdet_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/refclkout_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone0_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone1_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/clkin_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/gtpreset_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/plllkdet_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/refclkout_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone0_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone1_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/clkin_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/gtpreset_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/plllkdet_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/refclkout_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone0_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone1_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/clkin_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/gtpreset_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/plllkdet_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/refclkout_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone0_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone1_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/clkin_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/gtpreset_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/plllkdet_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/refclkout_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone0_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone1_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/clkin_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/gtpreset_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/plllkdet_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/refclkout_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone0_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone1_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/clkin_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/gtpreset_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/plllkdet_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/refclkout_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone0_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone1_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/clkin_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/gtpreset_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/plllkdet_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/refclkout_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone0_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone1_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/clkin_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/gtpreset_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/plllkdet_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/refclkout_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone0_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone1_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/clkin_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/gtpreset_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/plllkdet_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/refclkout_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone0_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone1_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/clkin_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/gtpreset_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/plllkdet_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/refclkout_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone0_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone1_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/clkin_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/gtpreset_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/plllkdet_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/refclkout_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone0_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone1_out
add wave -noupdate -group T0TX0
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txp0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txn0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txp0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txn0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txp0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txn0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txp0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txn0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txp0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txn0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txp0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txn0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txp0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txn0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txp0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txn0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txp0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txn0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txp0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txn0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txp0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txn0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txp0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txn0_out
add wave -noupdate -group {T0TX0 - TX Data Path Interface }
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txdata0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txoutclk0_out
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txcharisk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txreset0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk20_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txdata0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txoutclk0_out
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txcharisk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txreset0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk20_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txdata0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txoutclk0_out
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txcharisk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txreset0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk20_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txdata0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txoutclk0_out
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txcharisk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txreset0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk20_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txdata0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txoutclk0_out
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txcharisk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txreset0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk20_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txdata0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txoutclk0_out
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txcharisk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txreset0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk20_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txdata0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txoutclk0_out
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txcharisk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txreset0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk20_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txdata0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txoutclk0_out
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txcharisk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txreset0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk20_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txdata0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txoutclk0_out
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txcharisk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txreset0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk20_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txdata0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txoutclk0_out
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txcharisk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txreset0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk20_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txdata0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txoutclk0_out
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txcharisk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txreset0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk20_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txdata0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txoutclk0_out
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txcharisk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txreset0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk20_in
add wave -noupdate -group T0RX0
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxp0_in
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxn0_in
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxclkcorcnt0_out
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxlossofsync0_out
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxp0_in
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxn0_in
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxclkcorcnt0_out
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxlossofsync0_out
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxp0_in
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxn0_in
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxclkcorcnt0_out
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxlossofsync0_out
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxp0_in
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxn0_in
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxclkcorcnt0_out
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxlossofsync0_out
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxp0_in
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxn0_in
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxclkcorcnt0_out
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxlossofsync0_out
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxp0_in
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxn0_in
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxclkcorcnt0_out
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxlossofsync0_out
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxp0_in
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxn0_in
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxclkcorcnt0_out
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxlossofsync0_out
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxp0_in
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxn0_in
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxclkcorcnt0_out
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxlossofsync0_out
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxp0_in
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxn0_in
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxclkcorcnt0_out
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxlossofsync0_out
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxp0_in
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxn0_in
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxclkcorcnt0_out
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxlossofsync0_out
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxp0_in
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxn0_in
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxclkcorcnt0_out
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxlossofsync0_out
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxp0_in
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxn0_in
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxclkcorcnt0_out
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxlossofsync0_out
add wave -noupdate -group {T0RX0 - RX Data Path interface}
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdata0_out
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxreset0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk20_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdata0_out
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxreset0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk20_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdata0_out
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxreset0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk20_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdata0_out
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxreset0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk20_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdata0_out
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxreset0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk20_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdata0_out
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxreset0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk20_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdata0_out
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxreset0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk20_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdata0_out
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxreset0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk20_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdata0_out
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxreset0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk20_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdata0_out
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxreset0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk20_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdata0_out
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxreset0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk20_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdata0_out
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxreset0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk20_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment}
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyteisaligned0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyterealign0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcommadet0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenmcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenpcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyteisaligned0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyterealign0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcommadet0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenmcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenpcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyteisaligned0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyterealign0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcommadet0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenmcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenpcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyteisaligned0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyterealign0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcommadet0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenmcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenpcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyteisaligned0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyterealign0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcommadet0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenmcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenpcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyteisaligned0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyterealign0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcommadet0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenmcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenpcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyteisaligned0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyterealign0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcommadet0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenmcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenpcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyteisaligned0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyterealign0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcommadet0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenmcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenpcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyteisaligned0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyterealign0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcommadet0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenmcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenpcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyteisaligned0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyterealign0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcommadet0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenmcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenpcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyteisaligned0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyterealign0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcommadet0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenmcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenpcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyteisaligned0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyterealign0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcommadet0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenmcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenpcommaalign0_in
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align}
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufreset0_in
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufreset0_in
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufreset0_in
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufreset0_in
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufreset0_in
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufreset0_in
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufreset0_in
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufreset0_in
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufreset0_in
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufreset0_in
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufreset0_in
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufreset0_in
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxstatus0_out
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -format Logic /example_tb/reset_i
add wave -noupdate -format Logic /example_tb/connect
add wave -noupdate -format Logic /example_tb/tile0_plllkdet_i
add wave -noupdate -format Logic /example_tb/tile1_plllkdet_i
add wave -noupdate -format Logic /example_tb/lb_clk
add wave -noupdate -format Literal -radix hexadecimal /example_tb/lb_a
add wave -noupdate -format Logic /example_tb/lb_clk
add wave -noupdate -format Literal -radix hexadecimal /example_tb/lb_di
add wave -noupdate -format Literal -radix hexadecimal /example_tb/lb_do
add wave -noupdate -group {T0RX0 - 8b10b Decoder}
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxchariscomma0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcharisk0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdisperr0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxnotintable0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxchariscomma0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcharisk0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdisperr0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxnotintable0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxchariscomma0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcharisk0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdisperr0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxnotintable0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxchariscomma0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcharisk0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdisperr0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxnotintable0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxchariscomma0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcharisk0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdisperr0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxnotintable0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxchariscomma0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcharisk0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdisperr0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxnotintable0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxchariscomma0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcharisk0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdisperr0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxnotintable0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxchariscomma0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcharisk0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdisperr0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxnotintable0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxchariscomma0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcharisk0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdisperr0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxnotintable0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxchariscomma0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcharisk0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdisperr0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxnotintable0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxchariscomma0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcharisk0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdisperr0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxnotintable0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxchariscomma0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcharisk0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdisperr0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxnotintable0_out
add wave -noupdate -format Literal /example_tb/lb_loopback
add wave -noupdate -format Literal /example_tb/lb_rx_done
add wave -noupdate -format Literal /example_tb/lb_rx_err_cnt
add wave -noupdate -format Literal /example_tb/lb_rx_ok
add wave -noupdate -format Literal /example_tb/lb_rx_sz
add wave -noupdate -format Literal /example_tb/lb_tx_done
add wave -noupdate -format Literal /example_tb/lb_tx_start
add wave -noupdate -format Literal /example_tb/lb_tx_sz
add wave -noupdate -format Literal /example_tb/lb_we
add wave -noupdate -divider <NULL>
add wave -noupdate -divider TILE0_PCIEGTP_WRAPPER
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {15896120 ps} 0} {{Cursor 2} {16527120 ps} 0} {{Cursor 3} {210000 ps} 0} {{Cursor 4} {2779749 ps} 0}
configure wave -namecolwidth 265
configure wave -valuecolwidth 114
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {2701728 ps} {2870512 ps}
