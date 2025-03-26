TB_NAME ?= cache_mem_tb_top
TEST_NAME ?= cache_base_test
SEED ?= random
CMD_OPT ?=

#--------------------------------------------------------------------
DV_INCDIR :=
RTL_INCDIR :=
DV_SRC :=
RTL_SRC :=
VLOG_DEF :=
VSIM_RUN :=

#--------------------------------------------------------------------
UVM_DIR := +incdir+../../ext/uvm-core-2020.3.1/src
UVM_PKG := ../../ext/uvm-core-2020.3.1/src/uvm_pkg.sv

TB_SRC := tb/cache_mem_tb_top.sv

#--------------------------------------------------------------------
RTL_INCDIR += +incdir+../../rtl

#--------------------------------------------------------------------
DV_INCDIR += +incdir+./tb
DV_INCDIR += +incdir+./sv/test
DV_INCDIR += +incdir+./sv/seq
DV_INCDIR += +incdir+../lib
DV_INCDIR += +incdir+../lib/agent
DV_INCDIR += +incdir+../lib/interface

#--------------------------------------------------------------------
RTL_SRC += ../../rtl/cache_rtl_def.sv
RTL_SRC += ../../rtl/fsm_cpu_req_ctrl.sv
RTL_SRC += ../../rtl/fsm_bus_req_ctrl.sv
RTL_SRC += ../../rtl/cache_mem.sv

#--------------------------------------------------------------------
DV_SRC += ../lib/cache_lib_pkg.svh
DV_SRC += sv/cache_test_pkg.svh
DV_SRC += ../lib/interface/cache_if.sv

#--------------------------------------------------------------------
#VLOG_DEF += +define+UVM_HDL_NO_DPI
#VLOG_DEF += +define+UVM_NO_DPI
#VLOG_DEF += +define+UVM_CMDLINE_NO_DPI
#VLOG_DEF += +define+UVM_REGEX_NO_DPI

#--------------------------------------------------------------------
VSIM_RUN += log -r /*;
VSIM_RUN += run -all;
VSIM_RUN += quit;

#--------------------------------------------------------------------
runall: vlog vsim

#--------------------------------------------------------------------
clean:
	rm -rf work
	rm -rf vsim_stacktrace.vstf
	rm -rf transcript

#--------------------------------------------------------------------
vlog:
	mkdir -p run_dir wave_dir
	vlib work
	vlib work.uvm_pkg
	vlog -sv $(UVM_DIR) -work work.uvm_pkg $(UVM_PKG) $(VLOG_DEF)
	vlog -sv -lint $(RTL_INCDIR) $(DV_INCDIR) $(RTL_SRC) $(DV_SRC) $(TB_SRC) $(VLOG_DEF) -l run_dir/$(TEST_NAME).log

#--------------------------------------------------------------------
vsim:
	vsim work.$(TB_NAME) +UVM_TESTNAME=$(TEST_NAME) -nodpiexports -novopt -sv_seed $(SEED) $(CMD_OPT) -wlf wave_dir/$(TEST_NAME).wlf -do "$(VSIM_RUN)" | tee -a run_dir/$(TEST_NAME).log
	sed 's/^#//' run_dir/$(TEST_NAME).log > tmp.log && mv tmp.log run_dir/$(TEST_NAME).log
	sed -i '/  log -r \/\\*/d' run_dir/$(TEST_NAME).log
