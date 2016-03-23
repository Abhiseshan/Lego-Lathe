onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /multicycle_tb/reset
add wave -noupdate /multicycle_tb/clock
add wave -noupdate -divider {Hex Display}
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/HEX_display/in0
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/HEX_display/in1
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/HEX_display/in2
add wave -noupdate -divider {multicycle.v inputs}
add wave -noupdate /multicycle_tb/KEY
add wave -noupdate /multicycle_tb/SW
add wave -noupdate -divider {multicycle.v outputs}
add wave -noupdate /multicycle_tb/LEDG
add wave -noupdate /multicycle_tb/LEDR
add wave -noupdate /multicycle_tb/HEX0
add wave -noupdate /multicycle_tb/HEX1
add wave -noupdate /multicycle_tb/HEX2
add wave -noupdate /multicycle_tb/HEX3
add wave -noupdate /multicycle_tb/HEX4
add wave -noupdate /multicycle_tb/HEX5
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2500 ns} 0}
configure wave -namecolwidth 227
configure wave -valuecolwidth 57
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1000
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {2500 ns}
