// riscv_core_top_stub.sv — 产生三条“提交”的假核，便于把 TB 跑通
`include "riscv_defs.svh"

module riscv_core_top_stub(
  input  logic      clk,
  input  logic      rst_n,
  commit_if.drv     cmt   // 用 drv，stub 自己驱动通道
);
  typedef enum int unsigned {IDLE=0, S0, S1, S2, DONE} state_e;
  state_e st;

  // 预置三条提交（与 Mock Spike 一致）
  logic [63:0] pc_q   [3] = '{64'h0000_1000, 64'h0000_1004, 64'h0000_1008};
  logic [31:0] instr_q[3] = '{
     32'h0130_0093, // addi x1, x0, 0x13
     32'h0010_8113, // addi x2, x1, 1
     32'h0020_9193  // addi x3, x1, 2
  };
  logic [4:0]  rd_q   [3] = '{5'd1,5'd2,5'd3};
  logic [63:0] rdat_q [3] = '{64'd0+19, 64'd19+1, 64'd19+2};

  int idx;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= IDLE; idx <= 0;
      cmt.valid <= 1'b0;
    end else begin
      case (st)
        IDLE: begin
          cmt.valid <= 1'b0; st <= S0;
        end
        S0,S1,S2: begin
          cmt.valid    <= 1'b1;
          cmt.pc       <= pc_q[idx];
          cmt.instr    <= instr_q[idx];
          cmt.rd_addr  <= rd_q[idx];
          cmt.rd_data  <= rdat_q[idx];
          cmt.mem_we   <= 1'b0;
          cmt.mem_addr <= '0;
          cmt.mem_wdata<= '0;
          cmt.trap     <= 1'b0;
          cmt.priv     <= 2'd3; // M
          idx <= idx + 1;
          st  <= (idx==2) ? DONE : state_e'(st+1);
        end
        DONE: begin
          cmt.valid <= 1'b0; // 停止提交
        end
      endcase
    end
  end
endmodule
