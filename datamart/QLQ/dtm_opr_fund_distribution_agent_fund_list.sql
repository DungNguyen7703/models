/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_fund_distribution_agent_fund_list
* Program name: Dtm Opr Fund Distribution Agent Fund List
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-28		claude (draft)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_opr_fund_distribution_agent_fund_list_FMS_AGEN_FUNDS.csv
*                                       LLD atomic_table = fund_distribution_agent_x_investment_fund_relationship
*                                       -> ref atm_investment_fund_x_fund_distribution_agent_relationship (scd2, model thực tế cùng src FMS_AGEN_FUNDS)
* 2026-09-29		claude (draft)		Đổi nguồn atm_* sang bảng Dim QLQ tương ứng (dtm_*_dim_hstr) cho các entity đã có Dim
* 2026-10-07		claude				Đổi ref sang atm_fund_distribution_agent_x_investment_fund_relationship (Atomic đổi tên theo LLD)
* 2026-10-24		claude (sync)		Đồng bộ LLD commit 7164d9ca: thêm cột securities_distribution_agent_code (K_QLQ_143) — MIN mã ĐLPP
*                                       (dim ĐLPP src FMS_DISTRIBUTOR_AGENT) nối với đại lý (dim src FMS_AGENCIES) theo tên rút gọn
*                                       hoặc LOWER(TRIM(tên đầy đủ)); subquery tương quan LLD -> CTE GROUP BY + LEFT JOIN (schema-changing)
*--------------------------------------------------------------------*
*/

WITH fund_distribution_agent_x_investment_fund_relationship AS (
    SELECT
        CAST(fund_distribution_agent_id AS string)                              AS fund_distribution_agent_id,
        fund_distribution_agent_code,
        investment_fund_id,
        investment_fund_code,
        src_stm_code
    FROM {{ ref('atm_fund_distribution_agent_x_investment_fund_relationship') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_AGEN_FUNDS'
),

investment_fund AS (
    SELECT
        investment_fund_id,
        investment_fund_full_nm
    FROM {{ ref('dtm_investment_fund_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
),

fund_distribution_agent AS (
    SELECT
        fund_distribution_agent_id,
        fund_distribution_agent_full_nm,
        fund_distribution_agent_short_nm
    FROM {{ ref('dtm_fund_distribution_agent_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_AGENCIES'
),

securities_distribution_agent AS (
    SELECT
        securities_distribution_agent_code,
        securities_distribution_agent_full_nm,
        securities_distribution_agent_short_nm
    FROM {{ ref('dtm_securities_distribution_agent_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_DISTRIBUTOR_AGENT'
),

distribution_agent_map AS (
    SELECT
        fda.fund_distribution_agent_id,
        MIN(sda.securities_distribution_agent_code)                             AS securities_distribution_agent_code
    FROM fund_distribution_agent fda
    INNER JOIN securities_distribution_agent sda
        ON fda.fund_distribution_agent_short_nm = sda.securities_distribution_agent_short_nm
        OR LOWER(TRIM(fda.fund_distribution_agent_full_nm)) = LOWER(TRIM(sda.securities_distribution_agent_full_nm))
    GROUP BY fda.fund_distribution_agent_id
)

SELECT
    CAST(rltnp.fund_distribution_agent_code AS string)                                          AS fund_distribution_agent_code
    , CAST(rltnp.investment_fund_code AS string)                                                AS investment_fund_code
    , CAST(investment_fund.investment_fund_full_nm AS string)                                   AS investment_fund_full_nm
    , CAST(distribution_agent_map.securities_distribution_agent_code AS string)                 AS securities_distribution_agent_code
    , CAST(rltnp.src_stm_code AS string)                                                        AS src_stm_code
FROM fund_distribution_agent_x_investment_fund_relationship rltnp
LEFT JOIN investment_fund
    ON investment_fund.investment_fund_id = rltnp.investment_fund_id
LEFT JOIN distribution_agent_map
    ON CAST(distribution_agent_map.fund_distribution_agent_id AS string) = rltnp.fund_distribution_agent_id
