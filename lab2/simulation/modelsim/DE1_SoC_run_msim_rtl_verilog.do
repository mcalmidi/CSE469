transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/akhil/Desktop/cse469/lab1 {C:/Users/akhil/Desktop/cse469/lab1/fullAdder.sv}
vlog -sv -work work +incdir+C:/Users/akhil/Desktop/cse469/lab1 {C:/Users/akhil/Desktop/cse469/lab1/alu.sv}
