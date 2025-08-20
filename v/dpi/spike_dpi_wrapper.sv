// spike_dpi_wrapper.sv — SV 侧 DPI 封装，驱动“参考模型”通道
module spike_dpi_wrapper(
  input  logic     clk,
  input  logic     rst_n,
  commit_if.drv    cmt  // 作为参考模型驱动
);
  // DPI 函数（Mock 版本；后续可替换为真 Spike）
  import "DPI-C" function void dpi_spike_init(input string elf_path);
  import "DPI-C" function int  dpi_spike_next(
      output bit                  valid,
      output longint unsigned     pc,
      output int                  instr,
      output byte                 rd_addr,
      output longint unsigned     rd_data,
      output bit                  mem_we,
      output longint unsigned     mem_addr,
      output longint unsigned     mem_wdata,
      output bit                  trap,
      output byte                 priv
  );
  import "DPI-C" function void dpi_spike_fini();

  string elf_arg;
  bit    inited;

  initial begin
    if (!$value$plusargs("elf=%s", elf_arg)) elf_arg = "prog.elf";
    dpi_spike_init(elf_arg);
    inited = 1;
  end

  final begin
    dpi_spike_fini();
  end

  // 每拍从 DPI 拉取一次
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cmt.valid <= 1'b0;
    end else if (inited) begin
      bit v; longint unsigned pc; int instr;
      byte rda; longint unsigned rdd;
      bit mwe; longint unsigned ma, md;
      bit tr;  byte pv;
      void'(dpi_spike_next(v, pc, instr, rda, rdd, mwe, ma, md, tr, pv));
      cmt.valid    <= v;
      cmt.pc       <= pc;
      cmt.instr    <= instr;
      cmt.rd_addr  <= rda;
      cmt.rd_data  <= rdd;
      cmt.mem_we   <= mwe;
      cmt.mem_addr <= ma;
      cmt.mem_wdata<= md;
      cmt.trap     <= tr;
      cmt.priv     <= pv[1:0];
    end
  end
endmodule
