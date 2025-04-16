RTL_DIR := ../../rtl

RTL_INCDIR += +incdir+$(RTL_DIR)/topchip
RTL_INCDIR += +incdir+$(RTL_DIR)/subsystem

#--------------------------------------------------------------------
RTL_SRC += $(RTL_DIR)/topchip/cache_def.sv
RTL_SRC += $(RTL_DIR)/subsystem/fsm_cpu_req_ctrl.sv
RTL_SRC += $(RTL_DIR)/subsystem/fsm_bus_req_ctrl.sv
RTL_SRC += $(RTL_DIR)/topchip/cache_mem.sv
