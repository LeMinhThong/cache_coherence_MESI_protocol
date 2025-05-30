TB_NAME 	?= cache_mem_tb_top
TEST_NAME ?= cache_base_test_c
SEED 			?= random
CMD_OPT 	?=

#--------------------------------------------------------------------
DV_INCDIR 	:=
RTL_INCDIR 	:=
DV_SRC 			:=
RTL_SRC 		:=
VLOG_DEF 		:=
VSIM_RUN 		:=

#--------------------------------------------------------------------
UVM_DIR := +incdir+../../ext/uvm-core-2020.3.1/src
UVM_PKG := ../../ext/uvm-core-2020.3.1/src/uvm_pkg.sv

RTL_DIR 	:= ../../rtl
VIP_DIR 	:= ../lib
TEST_DIR 	:= ./sv
TB_DIR 		:= ./tb

#--------------------------------------------------------------------
RTL_INCDIR += +incdir+$(RTL_DIR)
RTL_INCDIR += +incdir+$(RTL_DIR)/topchip
RTL_INCDIR += +incdir+$(RTL_DIR)/subsystem

#--------------------------------------------------------------------
DV_INCDIR += +incdir+$(VIP_DIR)
DV_INCDIR += +incdir+$(VIP_DIR)/agent
DV_INCDIR += +incdir+$(VIP_DIR)/interface

DV_INCDIR += +incdir+$(TEST_DIR)/test
DV_INCDIR += +incdir+$(TEST_DIR)/seq

DV_INCDIR += +incdir+$(TB_DIR)

#--------------------------------------------------------------------
RTL_SRC += $(RTL_DIR)/topchip/cache_def.sv
RTL_SRC += $(RTL_DIR)/topchip/cache_pkg.sv
RTL_SRC += $(RTL_DIR)/topchip/cache_mem.sv
#RTL_SRC += $(RTL_DIR)/subsystem/fsm_l1_req_ctrl.sv
#RTL_SRC += $(RTL_DIR)/subsystem/fsm_snp_req_ctrl.sv

#--------------------------------------------------------------------
DV_SRC += $(VIP_DIR)/cache_vip_pkg.sv
DV_SRC += $(VIP_DIR)/if/cache_if.sv
DV_SRC += $(TEST_DIR)/cache_test_pkg.sv

#--------------------------------------------------------------------
TB_SRC := $(TB_DIR)/cache_mem_tb_top.sv

#--------------------------------------------------------------------
#VLOG_DEF += +define+UVM_HDL_NO_DPI
#VLOG_DEF += +define+UVM_NO_DPI
#VLOG_DEF += +define+UVM_CMDLINE_NO_DPI
#VLOG_DEF += +define+UVM_REGEX_NO_DPI

#--------------------------------------------------------------------
VSIM_RUN += log -r /*;
VSIM_RUN += run -all;
VSIM_RUN += quit -f;

#--------------------------------------------------------------------
runall: vlog vsim

#--------------------------------------------------------------------
clean:
	rm -rf work
	rm -rf vsim_stacktrace.vstf
	rm -rf transcript

#--------------------------------------------------------------------
vlog:
	mkdir -p run_dir wave_dir rtl_tracker
	vlib work
	vlib work.uvm_pkg
	vlog -sv $(UVM_DIR) -work work.uvm_pkg $(UVM_PKG) $(VLOG_DEF)
	vlog -sv -lint $(RTL_INCDIR) $(DV_INCDIR) $(RTL_SRC) $(DV_SRC) $(TB_SRC) $(VLOG_DEF) -l run_dir/$(TEST_NAME).log

#--------------------------------------------------------------------
vsim:
	vsim work.$(TB_NAME) +UVM_VERBOSITY=MEDIUM +UVM_TESTNAME=$(TEST_NAME) -nodpiexports -novopt -sv_seed $(SEED) $(CMD_OPT) -wlf wave_dir/$(TEST_NAME).wlf -do "$(VSIM_RUN)" | tee -a run_dir/$(TEST_NAME).log
	sed 's/^#//' run_dir/$(TEST_NAME).log > tmp.log && mv tmp.log run_dir/$(TEST_NAME).log
	sed -i '/  log -r \/\\*/d' run_dir/$(TEST_NAME).log
	rm -rf rtl_tracker/$(TEST_NAME).log

#--------------------------------------------------------------------
vlog_rtl:
	vlog -sv -lint $(RTL_INCDIR) $(RTL_SRC)
