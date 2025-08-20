// commit_if.sv — DUT/参考模型共享的提交通道 + 简要断言
interface commit_if(input logic clk, input logic rst_n);

  logic        valid;
  logic [63:0] pc;
  logic [31:0] instr;
  logic [4:0]  rd_addr;
  logic [63:0] rd_data;
  logic        mem_we;
  logic [63:0] mem_addr;
  logic [63:0] mem_wdata;
  logic        trap;
  logic [1:0]  priv; // 0:U 1:S 3:M

  // 驱动/监视用 modport
  modport drv (output valid,pc,instr,rd_addr,rd_data,mem_we,mem_addr,mem_wdata,trap,priv,
               input  clk,rst_n);
  modport mon (input  valid,pc,instr,rd_addr,rd_data,mem_we,mem_addr,mem_wdata,trap,priv,
               input  clk,rst_n);
  // DUT/REF 等价于 mon（只是区分名字）
  modport dut (input  valid,pc,instr,rd_addr,rd_data,mem_we,mem_addr,mem_wdata,trap,priv,
               input  clk,rst_n);
  modport ref (input  valid,pc,instr,rd_addr,rd_data,mem_we,mem_addr,mem_wdata,trap,priv,
               input  clk,rst_n);

  // ——最小 SVA——
  // reset 下 valid 必为 0
  property p_valid_low_in_reset;
    !rst_n |-> !valid;
  endproperty
  a_valid_low_in_reset: assert property (@(posedge clk) p_valid_low_in_reset);

  // 当 valid 拉高时，本拍信号不应为 X
  a_no_x_on_valid: assert property (@(posedge clk)
    valid |-> (!$isunknown(pc) && !$isunknown(instr)));

endinterface
