-- ────────────────────────────────────────────────────────────
-- Model : qlkd_opr_individual_trading_account_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Individual Trading Account
    o.sc_shareholder_code,
    o.sc_code,
    o.trading_account,
    o.shareholder_nm,
    o.src_stm_code

FROM {{ ref('dtm_opr_individual_trading_account') }} o