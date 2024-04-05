onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fullAdder_tb/A
add wave -noupdate /fullAdder_tb/B
add wave -noupdate /fullAdder_tb/cin
add wave -noupdate /fullAdder_tb/cout
add wave -noupdate /fullAdder_tb/sum
add wave -noupdate -radix decimal /fullAdder_tb/i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 104
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 10
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {86 ps}
