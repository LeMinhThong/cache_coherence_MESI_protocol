# Variables
TEST_NAME ?= cache_mem_tb_top
SEED ?= random

#VSIM_RUN =  \
    vcd file ${TEST_NAME}.vcd; \
    vcd add -r /*; \
    run -all; \
    vcd flush; \
    quit

VLOG_DEFINE = +define+UVM_HDL_NO_DPI \
							+define+UVM_NO_DPI \
							+define+UVM_CMDLINE_NO_DPI \
							+define+UVM_REGEX_NO_DPI

VSIM_RUN =  run -all;\
    				quit

all: build run

build:
	mkdir -p run_dir
	vlib work
	vlog -sv -lint -f FILES_vlog.vc -l run_dir/${TEST_NAME}.log ${VLOG_DEFINE}

run:
	vsim work.${TEST_NAME} -sv_seed ${SEED} -do "${VSIM_RUN}"| tee -a ${TEST_NAME}.log
	mv ${TEST_NAME}.log ./run_dir

clean:
	rm -rf run_dir
	rm -rf work
	rm -rf transcript
