-- ────────────────────────────────────────────────────────────
-- Model : qlq_opr_fund_management_company_fund_list_flat
-- Type  : OPERATIONAL
-- 2026-10-14 claude: thêm net_asset_val_amt theo dtm_opr_fund_management_company_fund_list (LLD commit 2f62880d)
--                    (schema-changing, cần ALTER bảng ClickHouse — ddl/20261014_qlq_ck_flat_sync.sql)
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Fund Management Company Fund List
    investment_fund_code,
    fmc_id,
    fmc_code,
    investment_fund_full_nm,
    fund_tp_code,
    net_asset_val_amt,
    src_stm_code

FROM {{ ref('dtm_opr_fund_management_company_fund_list') }}_hstr 
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND ds_rcrd_st = 'ACTIVE'