-- ────────────────────────────────────────────────────────────
-- Model : qlq_opr_fund_distribution_agent_profile_flat
-- Type  : OPERATIONAL
-- 2026-10-14 claude: thêm distributing_fund_count + 14 KPI báo cáo TinhHinhGiaoDichCCQ_06268 theo dtm_opr_fund_distribution_agent_profile
--                    (LLD commit 2f62880d; schema-changing, cần ALTER bảng ClickHouse — ddl/20261014_qlq_ck_flat_sync.sql)
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Fund Distribution Agent Profile
    securities_distribution_agent_code,
    securities_distribution_agent_full_nm,
    license_nbr,
    license_dt,
    address,
    active_status_flag,
    termination_dt,
    distributing_fund_count,
    trading_account_count,
    trading_account_year_to_dt_count,
    institution_trading_account_count,
    individual_trading_account_count,
    foreign_trading_account_count,
    institution_holding_account_count,
    individual_holding_account_count,
    foreign_holding_account_count,
    institution_fund_certificate_amt,
    individual_fund_certificate_amt,
    foreign_fund_certificate_amt,
    issued_amt,
    issued_year_to_dt_amt,
    redeemed_amt,
    src_stm_code

FROM {{ ref('dtm_opr_fund_distribution_agent_profile') }}_hstr
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND ds_rcrd_st = 'ACTIVE'