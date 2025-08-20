#!/usr/bin/env bash
set -e
rm -rf csrc simv* ucli.key *.log *.daidir DVEfiles *.so
VCS=vcs

$VCS -full64 -sverilog -ntb_opts uvm-1.2 \
  -timescale=1ns/1ns +acc +vpi \
  -cpp g++ -cc gcc \
  spike_dpi.cc \
  riscv_tb_top.sv ref_env_pkg.sv ref_scoreboard.sv \
  spike_dpi_wrapper.sv riscv_core_top_stub.sv commit_if.sv \
  -l comp.log

./simv +UVM_NO_RELNOTES +UVM_TESTNAME=smoke_test +elf=prog.elf -l sim.log
