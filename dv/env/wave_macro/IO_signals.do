onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cache_mem_tb_top/dut/clk
add wave -noupdate /cache_mem_tb_top/dut/rst_n
add wave -noupdate -group CDREQ /cache_mem_tb_top/dut/cdreq_valid
add wave -noupdate -group CDREQ /cache_mem_tb_top/dut/cdreq_op
add wave -noupdate -group CDREQ /cache_mem_tb_top/dut/cdreq_addr
add wave -noupdate -group CDREQ /cache_mem_tb_top/dut/cdreq_data
add wave -noupdate -group CDREQ /cache_mem_tb_top/dut/cdreq_ready
add wave -noupdate -group CURSP /cache_mem_tb_top/dut/cursp_valid
add wave -noupdate -group CURSP /cache_mem_tb_top/dut/cursp_rsp
add wave -noupdate -group CURSP /cache_mem_tb_top/dut/cursp_data
add wave -noupdate -group CURSP /cache_mem_tb_top/dut/cursp_ready
add wave -noupdate -group CUREQ /cache_mem_tb_top/dut/cureq_valid
add wave -noupdate -group CUREQ /cache_mem_tb_top/dut/cureq_op
add wave -noupdate -group CUREQ /cache_mem_tb_top/dut/cureq_addr
add wave -noupdate -group CUREQ /cache_mem_tb_top/dut/cureq_ready
add wave -noupdate -group CDRSP /cache_mem_tb_top/dut/cdrsp_valid
add wave -noupdate -group CDRSP /cache_mem_tb_top/dut/cdrsp_rsp
add wave -noupdate -group CDRSP /cache_mem_tb_top/dut/cdrsp_data
add wave -noupdate -group CDRSP /cache_mem_tb_top/dut/cdrsp_ready
add wave -noupdate /cache_mem_tb_top/dut/clk
add wave -noupdate -group SDREQ /cache_mem_tb_top/dut/sdreq_valid
add wave -noupdate -group SDREQ /cache_mem_tb_top/dut/sdreq_op
add wave -noupdate -group SDREQ /cache_mem_tb_top/dut/sdreq_addr
add wave -noupdate -group SDREQ /cache_mem_tb_top/dut/sdreq_data
add wave -noupdate -group SDREQ /cache_mem_tb_top/dut/sdreq_ready
add wave -noupdate -group SURSP /cache_mem_tb_top/dut/sursp_valid
add wave -noupdate -group SURSP /cache_mem_tb_top/dut/sursp_rsp
add wave -noupdate -group SURSP /cache_mem_tb_top/dut/sursp_data
add wave -noupdate -group SURSP /cache_mem_tb_top/dut/sursp_ready
add wave -noupdate -group SUREQ /cache_mem_tb_top/dut/sureq_valid
add wave -noupdate -group SUREQ /cache_mem_tb_top/dut/sureq_op
add wave -noupdate -group SUREQ /cache_mem_tb_top/dut/sureq_addr
add wave -noupdate -group SUREQ /cache_mem_tb_top/dut/sureq_ready
add wave -noupdate -group SDRSP /cache_mem_tb_top/dut/sdrsp_valid
add wave -noupdate -group SDRSP /cache_mem_tb_top/dut/sdrsp_rsp
add wave -noupdate -group SDRSP /cache_mem_tb_top/dut/sdrsp_data
add wave -noupdate -group SDRSP /cache_mem_tb_top/dut/sdrsp_ready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {197 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 85
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {585 ns}
