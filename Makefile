# Makefile — 选择仿真器并一键执行
.PHONY: all vcs questa clean

all: vcs

vcs:
	@chmod +x run_vcs
	./run_vcs

questa:
	vsim -version >/dev/null 2>&1 || (echo "Questa not found"; exit 1)
	vsim -c -do run_questa.tcl

clean:
	rm -rf work *.log simv* *.daidir csrc DVEfiles transcript vsim.wlf *.so ucli.key
