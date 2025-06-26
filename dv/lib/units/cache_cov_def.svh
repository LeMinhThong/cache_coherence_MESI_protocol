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

`endif
