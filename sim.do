if {[file isdirectory work]} {vdel -all -lib work}
vlib work
vmap work work

vlog -work work FPU_types.sv
vlog -work work FPU.sv
vlog -work work tbFPU.sv

vsim -voptargs=+acc work.tb_CFpu

quietly set StdArithNoWarnings 1
quietly set StdVitalGlitchNoWarnings 1

do wave.do
run 500ns