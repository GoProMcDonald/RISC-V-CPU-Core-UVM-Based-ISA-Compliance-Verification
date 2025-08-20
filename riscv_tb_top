// riscv_tb_top.sv — 顶层：时钟/复位、接口、DUT、参考模型、UVM 启动
`timescale 1ns/1ps
`include "riscv_defs.svh"

import uvm_pkg::*;
import ref_env_pkg::*;

module riscv_tb_top;
  // 1) clk/rst
  logic clk=0, rst_n=0;
  always #5 clk = ~clk;
  initial begin
    #0  rst_n=0;
    #50 rst_n=1;
  end

  // 2) 接口：DUT 与 参考模型各一份
  commit_if cmt_dut(.clk(clk), .rst_n(rst_n));
  commit_if cmt_ref(.clk(clk), .rst_n(rst_n));

  // 3) 实例：DUT stub + Mock Spike
  riscv_core_top_stub u_dut(.clk(clk), .rst_n(rst_n), .cmt(cmt_dut));
  spike_dpi_wrapper   u_ref(.clk(clk), .rst_n(rst_n), .cmt(cmt_ref));

  // 4) 将 interface 传给 UVM monitor
  initial begin
    uvm_config_db#(virtual commit_if.mon)::set(null, "uvm_test_top.env.dut_mon", "vif", cmt_dut); 
    uvm_config_db#(virtual commit_if.mon)::set(null, "uvm_test_top.env.ref_mon", "vif", cmt_ref);
  end

  // 5) 启动 UVM
  initial begin
    run_test("smoke_test");
  end
endmodule
