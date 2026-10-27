-- ────────────────────────────────────────────────────────────
-- Model : qlq_fct_investment_fund_ccq_snpst_flat
-- Type  : FACT
-- 2026-10-10 claude: thay 6 cột Classification Dimension (schema_code, schema_nm, cl_code, cl_nm, cl_nm_english,
--                    cl_description — luôn NULL) bằng thuộc tính từ dtm_fund_type_dim (nguồn atm_cl_fms_fund_type);
--                    FK fund_tp_cl_dim_id -> fund_type_id (schema-changing, cần ALTER/recreate bảng ClickHouse)
-- ────────────────────────────────────────────────────────────

WITH fact AS (
    SELECT
        snpst_dt_dim_id,
        fund_type_id,
        outstanding_unit_quantity,
        src_stm_code
    FROM {{ ref('dtm_fct_investment_fund_ccq_snpst') }}
    WHERE snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
),

dim_fund_type AS (
    SELECT
        fund_type_id,
        fund_type_code,
        fund_type_nm,
        open_fund_indicator
    FROM {{ ref('dtm_fund_type_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
      AND src_stm_code = 'FMS_FUND_TYPE'
)

SELECT
    -- FACT Fact Investment Fund CCQ Snapshot
    f.snpst_dt_dim_id,
    f.fund_type_id,
    f.outstanding_unit_quantity,
    f.src_stm_code,
    TO_DATE(f.snpst_dt_dim_id, 'yyyyMMdd')      AS snpst_cdr_dt,
    -- FUND TYPE DIMENSION
    ft.fund_type_code,
    ft.fund_type_nm,
    ft.open_fund_indicator

FROM fact f
LEFT JOIN dim_fund_type ft
    ON ft.fund_type_id = f.fund_type_id

