onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cache_mem_tb_top/dut/clk
add wave -noupdate /cache_mem_tb_top/dut/rst_n
add wave -noupdate /cache_mem_tb_top/dut/cdreq_ot
add wave -noupdate /cache_mem_tb_top/dut/cdreq_addr_bf
add wave -noupdate /cache_mem_tb_top/dut/cdreq_idx
add wave -noupdate /cache_mem_tb_top/dut/cdreq_way
add wave -noupdate -group cdreq_lookup /cache_mem_tb_top/dut/cache_lookup
add wave -noupdate -group cdreq_lookup /cache_mem_tb_top/dut/cac_hit
add wave -noupdate -group cdreq_lookup /cache_mem_tb_top/dut/cdreq_hit_way
add wave -noupdate -group cdreq_lookup /cache_mem_tb_top/dut/fill_inv_blk
add wave -noupdate -group cdreq_lookup /cache_mem_tb_top/dut/cdreq_inv_way
add wave -noupdate -group cdreq_lookup /cache_mem_tb_top/dut/repl_tree_n2
add wave -noupdate -group cdreq_lookup /cache_mem_tb_top/dut/repl_tree_n1
add wave -noupdate -group cdreq_lookup /cache_mem_tb_top/dut/repl_tree_n0
add wave -noupdate -group cdreq_lookup /cache_mem_tb_top/dut/evict_way
add wave -noupdate /cache_mem_tb_top/dut/sureq_ot
add wave -noupdate /cache_mem_tb_top/dut/sureq_addr_bf
add wave -noupdate /cache_mem_tb_top/dut/sureq_idx
add wave -noupdate /cache_mem_tb_top/dut/sureq_way
add wave -noupdate /cache_mem_tb_top/dut/snp_hit
add wave -noupdate -group repl /cache_mem_tb_top/dut/promote_ack
add wave -noupdate -group repl /cache_mem_tb_top/dut/promote_idx
add wave -noupdate -group repl /cache_mem_tb_top/dut/promote_way
add wave -noupdate -group repl /cache_mem_tb_top/dut/evict_way
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {132 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 206
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
WaveRestoreZoom {0 ns} {624 ns}
