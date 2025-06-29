rm run_dir/regr.log
make runall TEST_NAME=mesi_test_c REPL=PLRU USER_DEF=+define+HAS_SB
make runall TEST_NAME=repl_test_c REPL=PLRU USER_DEF=+define+HAS_SB
make runall TEST_NAME=corner_test_c REPL=PLRU USER_DEF=+define+HAS_SB
