// ref_env_pkg.sv — UVM 包：transaction / monitor / env / test
`include "uvm_macros.svh"
package ref_env_pkg;
  import uvm_pkg::*;
  `include "riscv_defs.svh"

  // —— 事务对象 ——
  class commit_tr extends uvm_sequence_item;
    `uvm_object_utils(commit_tr)
    commit_s s;
    function new(string name="commit_tr"); super.new(name); endfunction
    function string convert2string();
      return $sformatf("valid=%0b pc=0x%0h instr=0x%08h rd=x%0d data=%0d trap=%0b priv=%0d",
                       s.valid, s.pc, s.instr, s.rd_addr, s.rd_data, s.trap, s.priv);
    endfunction
  endclass

  // —— monitor：从 virtual interface 采样，写出 commit_s ——
  class cmt_monitor extends uvm_component;
    `uvm_component_utils(cmt_monitor)
    virtual commit_if.mon vif;
    uvm_analysis_port #(commit_s) ap;

    function new(string name, uvm_component parent); super.new(name,parent); ap=new("ap",this); endfunction
    function void build_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual commit_if.mon)::get(this,"","vif",vif))
        `uvm_fatal("NOVIF","monitor needs vif")
    endfunction

    task run_phase(uvm_phase phase);
      commit_s s;
      forever begin
        @(posedge vif.clk);
        if (!vif.rst_n) continue;
        if (vif.valid) begin
          s.valid    = vif.valid;
          s.pc       = vif.pc;
          s.instr    = vif.instr;
          s.rd_addr  = vif.rd_addr;
          s.rd_data  = vif.rd_data;
          s.mem_we   = vif.mem_we;
          s.mem_addr = vif.mem_addr;
          s.mem_wdata= vif.mem_wdata;
          s.trap     = vif.trap;
          s.priv     = priv_e'(vif.priv);
          ap.write(s);
        end
      end
    endtask
  endclass

  // 引入 scoreboard 类
  `include "ref_scoreboard.sv"

  // —— env —— 两个 monitor + scoreboard
  class ref_env extends uvm_env;
    `uvm_component_utils(ref_env)
    cmt_monitor      dut_mon;
    cmt_monitor      ref_mon;
    ref_scoreboard   sb;

    function new(string name, uvm_component parent); super.new(name,parent); endfunction

    function void build_phase(uvm_phase phase);
      dut_mon = cmt_monitor::type_id::create("dut_mon", this);
      ref_mon = cmt_monitor::type_id::create("ref_mon", this);
      sb      = ref_scoreboard ::type_id::create("sb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      dut_mon.ap.connect(sb.imp_dut);
      ref_mon.ap.connect(sb.imp_ref);
    endfunction
  endclass

  // —— test —— 构建 env，等待比较完成
  class smoke_test extends uvm_test;
    `uvm_component_utils(smoke_test)
    ref_env env;
    function new(string name, uvm_component parent=null); super.new(name,parent); endfunction
    function void build_phase(uvm_phase phase);
      env = ref_env::type_id::create("env", this);
    endfunction
  endclass

endpackage
