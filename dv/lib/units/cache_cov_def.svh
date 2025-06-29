`ifndef CACHE_COV_DEF_SVH
`define CACHE_COV_DEF_SVH

`define CP_STATE_COV \
    CP_STATE_COV: coverpoint m_txn.State { \
          bins CB_INVALID   = {INVALID  }; \
          bins CB_EXCLUSIVE = {EXCLUSIVE}; \
          bins CB_SHARED    = {SHARED   }; \
          bins CB_MODIFIED  = {MODIFIED }; \
          bins CB_MIGRATED  = {MIGRATED }; \
    }

`define CROSS_CB_2(name, cp1, cb1, cp2, cb2)      bins          name = binsof(cp1) intersect {cb1} && binsof(cp2) intersect {cb2};
`define CROSS_ILL_CB_2(name, cp1, cb1, cp2, cb2)  illegal_bins  name = binsof(cp1) intersect {cb1} && binsof(cp2) intersect {cb2};

`define CROSS_CB_3(name, cp1, cb1, cp2, cb2, cp3, cb3)      bins          name = binsof(cp1) intersect {cb1} && binsof(cp2) intersect {cb2} && binsof(cp3) intersect {cb3};
`define CROSS_ILL_CB_3(name, cp1, cb1, cp2, cb2, cp3, cb3)  illegal_bins  name = binsof(cp1) intersect {cb1} && binsof(cp2) intersect {cb2} && binsof(cp3) intersect {cb3};

`endif
