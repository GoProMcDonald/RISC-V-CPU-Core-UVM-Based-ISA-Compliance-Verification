# run_questa.tcl — compile & run
vlib work
vlog -sv -timescale 1ns/1ns +acc=rn \
     riscv_tb_top.sv ref_env_pkg.sv ref_scoreboard.sv \
     spike_dpi_wrapper.sv riscv_core_top_stub.sv commit_if.sv

# 编译 Mock DPI 为共享库（Linux）
exec g++ -shared -fPIC -std=c++11 -o spike_dpi.so spike_dpi.cc

vsim -c -sv_lib ./spike_dpi -do "run -all; quit" riscv_tb_top \
     -voptargs=+acc +UVM_TESTNAME=smoke_test +elf=prog.elf
