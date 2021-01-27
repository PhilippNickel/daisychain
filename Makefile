SRC+=dff.sv 
SRC+=register_cell.sv 
SRC+=shift_register.sv 
SRC+=serial_ctrl.sv 
SRC_TB+=testbench.sv
sim_all:	
	vlog -sv -timescale 1ns/1ps $(SRC)
	vlog -sv -timescale 1ns/1ps $(SRC_TB) 
	vsim  -voptargs="+acc" testbench 
sim_shift_reg: 
	vlog -sv -timescale 1ns/1ps dff.sv register_cell.sv shift_register.sv
	vlog -sv -timescale 1ns/1ps testbench_shift_reg.sv
	vsim -voptargs="+acc" testbench_shift_reg

