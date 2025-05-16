#find agent/ cache_type.svh -type f -exec sed -i 's/sut_e_/sut_/g;' {} +
find rtl/subsystem/ rtl/topchip/ dv/lib/agent/ dv/lib/if/ dv/lib/cache_type.svh dv/env/tb/ dv/env/sv/ -type f -exec sed -i 's/CDR_/CDREQ_/g;s/CDT_/CURSP_/g;s/CUT_/CUREQ_/g;s/CUR_/CDRSP_/g;s/SDT_/SDREQ_/g;s/SDR_/SURSP_/g;s/SUR_/SUREQ_/g;s/SUT_/SDRSP_/g;' {} +

#cdr_ --> cdreq_
#cdt_ --> cursp_
#cut_ --> cureq_
#cur_ --> cdrsp_
#sdt_ --> sdreq_
#sdr_ --> sursp_
#sur_ --> sureq_
#sut_ --> sdrsp_
