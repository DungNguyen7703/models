/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_fund_distribution_agent_snpst
* Program name: Dtm Fct Fund Distribution Agent Snpst
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-28		claude (draft)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_fct_fund_distribution_agent_snpst.csv
*                                       CHƯA CÓ model atm_securities_distribution_agent; ip_alternative_identification
*                                       chưa có nhánh FMS_DISTRIBUTOR_AGENT -> enabled: false trong schema_dtm_qlq.yml
*                                       Grain: 1 dòng toàn thị trường / snapshot
* 2026-09-29		claude (draft)		Đổi nguồn atm_* sang bảng Dim QLQ tương ứng (dtm_*_dim_hstr) cho các entity đã có Dim
* 2026-10-07		claude (sync)		Đồng bộ LLD theo Atomic FMS UAT 20261006 (commit 117654ae, 53443cc1): điều kiện đang hoạt động = termination_dt IS NULL
*                                       (Atomic không còn active_status_flag)
* 2026-10-14		claude (sync)		Đồng bộ LLD commit d18cdaa0: loại giấy tờ OPERATION_LICENSE -> ESTABLISHMENT_OPERATION_LICENSE
*--------------------------------------------------------------------*
*/

WITH securities_distribution_agent AS (
    SELECT
        securities_distribution_agent_id,
        termination_dt
    FROM {{ ref('dtm_securities_distribution_agent_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_DISTRIBUTOR_AGENT'
),

operation_license AS (
    SELECT DISTINCT
        ip_id
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_DISTRIBUTOR_AGENT'
        AND identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'
        AND identification_issue_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
)

SELECT
    date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')                     AS snpst_dt_dim_id,
    CAST(COUNT(CASE WHEN securities_distribution_agent.termination_dt IS NULL
                        AND operation_license.ip_id IS NOT NULL
                    THEN securities_distribution_agent.securities_distribution_agent_id END) AS int) AS distribution_agent_count
FROM securities_distribution_agent
LEFT JOIN operation_license
    ON operation_license.ip_id = securities_distribution_agent.securities_distribution_agent_id
