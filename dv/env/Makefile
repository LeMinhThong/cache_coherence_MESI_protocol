# Variables
TB_NAME ?= cache_mem_tb_top
TEST_NAME ?= cache_base_test
SEED ?= random
CMD_OPT ?=

VLOG_DEFINE = +define+UVM_HDL_NO_DPI \
							+define+UVM_NO_DPI \
							+define+UVM_CMDLINE_NO_DPI \
							+define+UVM_REGEX_NO_DPI

VSIM_RUN =  log -r /*;\
						run -all;\
    				quit

all: build run

build:
	mkdir -p run_dir wave_dir
	vlib work
	vlog -sv -lint -f FILES_vlog.vc -l run_dir/${TEST_NAME}.log ${VLOG_DEFINE}
run:
	vsim work.${TB_NAME} +UVM_TESTNAME=${TEST_NAME} -sv_seed ${SEED} ${CMD_OPT} -wlf wave_dir/${TEST_NAME}.wlf -do "${VSIM_RUN}" | tee -a run_dir/${TEST_NAME}.log
	sed 's/^#//' run_dir/${TEST_NAME}.log > temp_file.log && mv temp_file.log run_dir/${TEST_NAME}.log
clean:
	rm -rf work
	rm -rf transcript
	rm -rf vsim_stacktrace.vstf
