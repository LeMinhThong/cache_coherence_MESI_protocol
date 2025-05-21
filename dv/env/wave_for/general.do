onerror {resume}
quietly virtual signal -install /cache_mem_tb_top/dut {/cache_mem_tb_top/dut/tx_l1_data  } fds
quietly virtual function -install /cache_mem_tb_top/dut -env /cache_mem_tb_top/dut { &{/cache_mem_tb_top/dut/l1_wr, /cache_mem_tb_top/dut/l1_rd }} wr_rd
quietly virtual function -install /cache_mem_tb_top/dut -env /cache_mem_tb_top/dut { &{/cache_mem_tb_top/dut/wr_hit, /cache_mem_tb_top/dut/rd_hit, /cache_mem_tb_top/dut/wr_miss, /cache_mem_tb_top/dut/rd_miss }} wr_rd_hit_miss
quietly virtual function -install /cache_mem_tb_top/dut -env /cache_mem_tb_top/dut { &{/cache_mem_tb_top/dut/wr_hit, /cache_mem_tb_top/dut/wr_miss, /cache_mem_tb_top/dut/rd_hit, /cache_mem_tb_top/dut/rd_miss }} wr_rd_hit_miss001
quietly WaveActivateNextPane {} 0
add wave -noupdate /cache_mem_tb_top/dut/clk
add wave -noupdate /cache_mem_tb_top/dut/rst_n
add wave -noupdate -group rx_l1 /cache_mem_tb_top/dut/rx_l1_op
add wave -noupdate -group rx_l1 /cache_mem_tb_top/dut/rx_l1_addr
add wave -noupdate -group rx_l1 -group data /cache_mem_tb_top/dut/rx_l1_data
add wave -noupdate -group tx_l1 /cache_mem_tb_top/dut/tx_l1_wait
add wave -noupdate -group tx_l1 -expand -group data /cache_mem_tb_top/dut/tx_l1_data
add wave -noupdate -group down_snp /cache_mem_tb_top/dut/tx_snp_op
add wave -noupdate -group down_snp /cache_mem_tb_top/dut/tx_snp_addr
add wave -noupdate -group down_snp /cache_mem_tb_top/dut/rx_snp_rsp
add wave -noupdate -group down_snp -expand -group data /cache_mem_tb_top/dut/rx_snp_data
add wave -noupdate -group up_snp /cache_mem_tb_top/dut/rx_snp_op
add wave -noupdate -group up_snp /cache_mem_tb_top/dut/rx_snp_addr
add wave -noupdate -group up_snp /cache_mem_tb_top/dut/tx_snp_rsp
add wave -noupdate -group up_snp -group data /cache_mem_tb_top/dut/tx_snp_data
add wave -noupdate /cache_mem_tb_top/dut/wr_rd
add wave -noupdate -label wr_rd_hit_miss /cache_mem_tb_top/dut/wr_rd_hit_miss001
add wave -noupdate /cache_mem_tb_top/dut/l1_req
add wave -noupdate /cache_mem_tb_top/dut/l1_hit
add wave -noupdate /cache_mem_tb_top/dut/snp_hit
add wave -noupdate /cache_mem_tb_top/dut/l1_req_blk_curSt
add wave -noupdate /cache_mem_tb_top/dut/snp_req_blk_curSt
add wave -noupdate /cache_mem_tb_top/dut/snp_req_blk_nxtSt
add wave -noupdate /cache_mem_tb_top/dut/snp_ret_dat
add wave -noupdate /cache_mem_tb_top/dut/_tx_snp_rsp
add wave -noupdate /cache_mem_tb_top/dut/wr_hit
add wave -noupdate /cache_mem_tb_top/dut/wr_miss
add wave -noupdate /cache_mem_tb_top/dut/rd_hit
add wave -noupdate /cache_mem_tb_top/dut/rd_miss
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {66 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 170
configure wave -valuecolwidth 165
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
WaveRestoreZoom {0 ns} {184 ns}
