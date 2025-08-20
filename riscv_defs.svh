// riscv_defs.svh — 公共类型/宏
`ifndef RISCV_DEFS_SVH
`define RISCV_DEFS_SVH

typedef enum bit [1:0] {
  PRIV_U = 2'd0,
  PRIV_S = 2'd1,
  PRIV_M = 2'd3
} priv_e;

// 统一的“提交记录”结构（用于类里存储/打印；DPI 仍按标量传递）
typedef struct packed {
  bit              valid;
  logic [63:0]     pc;
  logic [31:0]     instr;
  logic [4:0]      rd_addr;
  logic [63:0]     rd_data;
  bit              mem_we;
  logic [63:0]     mem_addr;
  logic [63:0]     mem_wdata;
  bit              trap;
  priv_e           priv;
} commit_s;

`endif
