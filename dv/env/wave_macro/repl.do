onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cache_mem_tb_top/dut/clk
add wave -noupdate /cache_mem_tb_top/dut/cdreq_ot
add wave -noupdate /cache_mem_tb_top/dut/cdreq_op_bf
add wave -noupdate /cache_mem_tb_top/dut/cdreq_addr_bf
add wave -noupdate /cache_mem_tb_top/dut/cdreq_data_bf
add wave -noupdate /cache_mem_tb_top/dut/cac_hit
add wave -noupdate /cache_mem_tb_top/dut/cdreq_hit_way
add wave -noupdate /cache_mem_tb_top/dut/fill_inv_blk
add wave -noupdate /cache_mem_tb_top/dut/cdreq_inv_way
add wave -noupdate /cache_mem_tb_top/dut/tree_bit
add wave -noupdate /cache_mem_tb_top/dut/evict_way
add wave -noupdate /cache_mem_tb_top/dut/cdreq_way
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {116 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 233
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
WaveRestoreZoom {0 ns} {2294 ns}
