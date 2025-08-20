// spike_dpi.cc — Mock Spike：返回三条固定提交，便于环境闭环验证
#include "svdpi.h"
#include <cstdint>
#include <string>
#include <vector>

struct Commit
{
  bool valid;
  uint64_t pc;
  uint32_t instr;
  uint8_t rd_addr;
  uint64_t rd_data;
  bool mem_we;
  uint64_t mem_addr;
  uint64_t mem_wdata;
  bool trap;
  uint8_t priv;
};

static std::vector<Commit> trace;
static size_t idx = 0;

extern "C" void dpi_spike_init(const char *elf_path)
{
  (void)elf_path; // Mock 不解析 ELF
  trace.clear();
  // 与 stub 内核保持一致
  trace.push_back({true, 0x00001000ULL, 0x01300093u, 1, 19ULL, false, 0, 0, false, 3});
  trace.push_back({true, 0x00001004ULL, 0x00108113u, 2, 20ULL, false, 0, 0, false, 3});
  trace.push_back({true, 0x00001008ULL, 0x00209193u, 3, 21ULL, false, 0, 0, false, 3});
  idx = 0;
}

extern "C" int dpi_spike_next(
    svBit *valid,
    unsigned long long *pc,
    int *instr,
    unsigned char *rd_addr,
    unsigned long long *rd_data,
    svBit *mem_we,
    unsigned long long *mem_addr,
    unsigned long long *mem_wdata,
    svBit *trap,
    unsigned char *priv)
{
  if (idx < trace.size())
  {
    const Commit &c = trace[idx++];
    *valid = c.valid ? 1 : 0;
    *pc = c.pc;
    *instr = (int)c.instr;
    *rd_addr = c.rd_addr;
    *rd_data = c.rd_data;
    *mem_we = c.mem_we ? 1 : 0;
    *mem_addr = c.mem_addr;
    *mem_wdata = c.mem_wdata;
    *trap = c.trap ? 1 : 0;
    *priv = c.priv;
    return 1; // 有数据
  }
  else
  {
    *valid = 0;
    return 0; // 本拍无提交
  }
}

extern "C" void dpi_spike_fini()
{
  // no-op for mock
}
