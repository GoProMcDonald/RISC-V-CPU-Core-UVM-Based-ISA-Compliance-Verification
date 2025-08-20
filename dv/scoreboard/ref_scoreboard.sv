// ref_scoreboard.sv — 基于分析端口的比对器（被 package include）
class ref_scoreboard extends uvm_component;
  `uvm_component_utils(ref_scoreboard)

  // 从两个 monitor 接收
  uvm_analysis_imp #(commit_s, ref_scoreboard) imp_dut;
  uvm_analysis_imp #(commit_s, ref_scoreboard) imp_ref;

  commit_s dut_q[$];
  commit_s ref_q[$];

  int unsigned match_cnt, mismatch_cnt;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    imp_dut = new("imp_dut", this);
    imp_ref = new("imp_ref", this);
  endfunction

  // 两个 write 同名需区分，这里用 type-wide write，并靠 get_active_imp() 判断
  virtual function void write(commit_s tr);
    uvm_analysis_imp_base imp = get_active_imp();
    if (imp == imp_dut)      dut_q.push_back(tr);
    else if (imp == imp_ref) ref_q.push_back(tr);
    compare_queues();
  endfunction

  task compare_queues();
    // 尽可能对齐逐一比对（这里按到达顺序）
    while (dut_q.size() > 0 && ref_q.size() > 0) begin
      commit_s a = dut_q.pop_front();
      commit_s b = ref_q.pop_front();
      if (a.valid != b.valid) begin
        `uvm_error("CMP", $sformatf("valid mismatch: dut=%0b ref=%0b @pc=0x%0h/0x%0h", a.valid,b.valid,a.pc,b.pc))
        mismatch_cnt++;
      end else if (a.valid && b.valid) begin
        bit ok = 1;
        ok &= (a.pc     == b.pc);
        ok &= (a.instr  == b.instr);
        ok &= (a.rd_addr== b.rd_addr);
        ok &= (a.rd_data== b.rd_data);
        ok &= (a.trap   == b.trap);
        if (!ok) begin
          `uvm_error("CMP", $sformatf("Mismatch: PC 0x%0h vs 0x%0h, instr 0x%08h/0x%08h, rd x%0d data %0d/%0d",
                       a.pc,b.pc,a.instr,b.instr,a.rd_addr,a.rd_data,b.rd_data))
          mismatch_cnt++;
        end else begin
          match_cnt++;
          `uvm_info("CMP", $sformatf("Match PC=0x%0h rd x%0d = %0d", a.pc, a.rd_addr, a.rd_data), UVM_LOW)
        end
      end
    end
  endtask

  function void report_phase(uvm_phase phase);
    `uvm_info("SUM", $sformatf("Matches=%0d Mismatches=%0d", match_cnt, mismatch_cnt), UVM_NONE)
    if (mismatch_cnt == 0 && match_cnt > 0)
      `uvm_info("PASS", "DUT == REF (mock) — PASS", UVM_NONE)
    else if (match_cnt==0)
      `uvm_warning("EMPTY", "No commits compared.")
  endfunction
endclass
