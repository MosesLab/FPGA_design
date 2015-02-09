onerror {resume}
quietly WaveActivateNextPane {} 0
quietly virtual signal -install /example_tb/example_mgt_top_i/tile0_frame_check0 { /example_tb/example_mgt_top_i/tile0_frame_check0/bram_data_r(7 downto 0)} bram_r_7to0
quietly virtual signal -install /example_tb/example_mgt_top_i/tile0_frame_check0 { /example_tb/example_mgt_top_i/tile0_frame_check0/bram_data_r2(7 downto 0)} bram_r2_7to0
add wave -noupdate -format Logic /example_tb/reset_i
add wave -noupdate -format Logic /example_tb/connect
add wave -noupdate -format Literal -radix hexadecimal /example_tb/t0ch0_framecheck_cnt
add wave -noupdate -format Logic /example_tb/tile0_plllkdet_i
add wave -noupdate -divider TILE0_PCIEGTP_WRAPPER
add wave -noupdate -expand -group {T0 - Share Tile and PLL}
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/clkin_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/gtpreset_in
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/plllkdet_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/refclkout_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone0_out
add wave -noupdate -group {T0 - Share Tile and PLL} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/resetdone1_out
add wave -noupdate -divider {TILE0, CH0}
add wave -noupdate -expand -group {T0CH0 - Frame Check}
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic /example_tb/example_mgt_top_i/tile0_frame_check0/user_clk
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic /example_tb/example_mgt_top_i/tile0_frame_check0/system_reset
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic /example_tb/example_mgt_top_i/tile0_frame_check0/rx_enchan_sync
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic /example_tb/example_mgt_top_i/tile0_frame_check0/rx_enmcomma_align
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic /example_tb/example_mgt_top_i/tile0_frame_check0/rx_enpcomma_align
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic /example_tb/example_mgt_top_i/tile0_frame_check0/reset_on_error
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic /example_tb/example_mgt_top_i/tile0_frame_check0/inc_in
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic -label {inc_out - follows start_of_packet_detected_c} /example_tb/example_mgt_top_i/tile0_frame_check0/inc_out
add wave -noupdate -group {T0CH0 - Frame Check} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/tile0_frame_check0/error_count
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic /example_tb/example_mgt_top_i/tile0_frame_check0/begin_r
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic /example_tb/example_mgt_top_i/tile0_frame_check0/track_data_r
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic /example_tb/example_mgt_top_i/tile0_frame_check0/track_data_r2
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic /example_tb/example_mgt_top_i/tile0_frame_check0/track_data_r3
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic /example_tb/example_mgt_top_i/tile0_frame_check0/data_error_detected_r
add wave -noupdate -group {T0CH0 - Frame Check} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/tile0_frame_check0/rx_data
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic /example_tb/example_mgt_top_i/tile0_frame_check0/rx_data_has_start_char_c
add wave -noupdate -group {T0CH0 - Frame Check} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/tile0_frame_check0/rx_data_r
add wave -noupdate -group {T0CH0 - Frame Check} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/tile0_frame_check0/rx_data_r2
add wave -noupdate -group {T0CH0 - Frame Check} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/tile0_frame_check0/rx_data_r3
add wave -noupdate -group {T0CH0 - Frame Check} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/tile0_frame_check0/rx_data_r4
add wave -noupdate -group {T0CH0 - Frame Check} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/tile0_frame_check0/read_counter_i
add wave -noupdate -group {T0CH0 - Frame Check} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/tile0_frame_check0/bram_r_7to0
add wave -noupdate -group {T0CH0 - Frame Check} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/tile0_frame_check0/bram_r2_7to0
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic /example_tb/example_mgt_top_i/tile0_frame_check0/rx_data_matches_bram_c
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic /example_tb/example_mgt_top_i/tile0_frame_check0/error_detected_c
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic /example_tb/example_mgt_top_i/tile0_frame_check0/error_detected_r
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic -label {pattern_match_n (follows error detected)} /example_tb/example_mgt_top_i/tile0_frame_check0/pattern_match_n
add wave -noupdate -group {T0CH0 - Frame Check} -format Literal /example_tb/example_mgt_top_i/tile0_frame_check0/config_independent_lanes
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic /example_tb/example_mgt_top_i/tile0_frame_check0/start_of_packet_detected_c
add wave -noupdate -group {T0CH0 - Frame Check} -format Logic /example_tb/example_mgt_top_i/tile0_frame_check0/start_of_packet_detected_r
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -format Literal -radix hexadecimal -expand /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/loopback0_in
add wave -noupdate -expand -group T0TX0
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txp0_out
add wave -noupdate -group T0TX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txn0_out
add wave -noupdate -expand -group {T0TX0 - TX Data Path Interface }
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txdata0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txoutclk0_out
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txcharisk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txreset0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk0_in
add wave -noupdate -group {T0TX0 - TX Data Path Interface } -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/txusrclk20_in
add wave -noupdate -expand -group T0RX0
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxp0_in
add wave -noupdate -group T0RX0 -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxn0_in
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxclkcorcnt0_out
add wave -noupdate -group T0RX0 -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxlossofsync0_out
add wave -noupdate -expand -group {T0RX0 - RX Data Path interface}
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Literal -radix hexadecimal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdata0_out
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxreset0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk0_in
add wave -noupdate -group {T0RX0 - RX Data Path interface} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxusrclk20_in
add wave -noupdate -expand -group {T0RX0 - 8b10b Decoder}
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxchariscomma0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcharisk0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxdisperr0_out
add wave -noupdate -group {T0RX0 - 8b10b Decoder} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxnotintable0_out
add wave -noupdate -expand -group {T0RX0 - Comma Detection and Alignment}
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyteisaligned0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbyterealign0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxcommadet0_out
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenmcommaalign0_in
add wave -noupdate -group {T0RX0 - Comma Detection and Alignment} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxenpcommaalign0_in
add wave -noupdate -expand -group {T0RX0 - RX Elastic Buffer and Phase Align}
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Logic /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufreset0_in
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxbufstatus0_out
add wave -noupdate -group {T0RX0 - RX Elastic Buffer and Phase Align} -format Literal /example_tb/example_mgt_top_i/pciegtp_wrapper_i/tile0_pciegtp_wrapper_i/rxstatus0_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {974447 ps} 0} {{Cursor 2} {16166222 ps} 0} {{Cursor 3} {10547120 ps} 0} {{Cursor 4} {16252120 ps} 0}
configure wave -namecolwidth 375
configure wave -valuecolwidth 60
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
WaveRestoreZoom {16139296 ps} {16223198 ps}
