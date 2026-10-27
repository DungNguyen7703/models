/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_securities_company_compliance_report_snpst
* Program name: Dtm Fct Securities Company Compliance Report Snpst
* Created by: tuan.nguyenvanb
* Created date: 2026-09-15
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-15		tuan.nguyenvanb		[MOI, theo LLD cap nhat 2026-09-12 - commit
*                                       2365025e] Thay the hoan toan dtm_fct_securities_
*                                       company_service_registration + dtm_service_tp_dim
*                                       (da xoa khoi thiet ke). Grain: 1 dong / CTCK /
*                                       loai bao cao (ADHOC hoac PERIODIC) / 1 ban ghi
*                                       bao cao - UNION ALL 2 nguon atomic doc lap
*                                       (atm_sc_adhoc_report + atm_sc_periodic_report),
*                                       KHONG tinh toan lai on_time/late/overdue count
*                                       nhu ban thiet ke cu (report_submission_obligation/
*                                       member_periodic_report khong con dung nua).
*                                       snpst_dt_dim_id la FK ngay chay ETL (:etl_date),
*                                       KHONG phai ngay cua tung ban ghi bao cao.
* 2026-10-19		claude				[SUA] Bo sung 7 cot bi thieu du LLD da
*                                       dac ta du etl_logic: sent_dt,
*                                       submission_deadline_dt, rpt_year,
*                                       rpt_period_tp_code, period_nbr,
*                                       period_val, created_dt.
* 2026-10-21		claude				[SUA] Dinh chinh comment: cot
*                                       atm_sc_adhoc_report.src_rcrd_isrt_tms
*                                       da ton tai trong Atomic (lay tu
*                                       created_at), KHONG con thieu nhu ghi
*                                       chu truoc do. created_dt bo ADHOC lay
*                                       truc tiep gia tri that tu cot nay,
*                                       khong phai NULL. created_dt bo
*                                       PERIODIC van la NULL dung theo LLD
*                                       (khong ap dung cho bao cao dinh ky).
*--------------------------------------------------------------------*
*/

WITH cd_dt_di AS (
    SELECT cdr_dt_dim_id, cdr_dt
    FROM {{ ref('dtm_cdr_dt_dim') }}
    WHERE cdr_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

se_co_di AS (
    SELECT securities_company_dim_id, sc_code
    FROM {{ ref('dtm_securities_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

-- Bo ADHOC
adhoc_rpt AS (
    SELECT
        sc_code,
        CAST('ADHOC' AS string)            AS report_tp_code,
        CAST(sc_adhoc_rpt_id AS string)    AS report_id,
        rpt_submission_status_code,
        CAST(sent_tms AS date)              AS sent_dt,
        CAST(submission_deadline_tms AS date) AS submission_deadline_dt,
        rpt_year,
        CAST(NULL AS string)                AS rpt_period_tp_code,
        CAST(NULL AS int)                   AS period_nbr,
        period_val,
        CAST(src_rcrd_isrt_tms AS date)     AS created_dt,
        src_stm_code,
        rpt_nm
    FROM {{ ref('atm_sc_adhoc_report') }}
    WHERE src_stm_code = 'SCMS_SC_FIRM_ADHOC_REPORT'
),

-- Bo PERIODIC
periodic_rpt AS (
    SELECT
        sc_code,
        CAST('PERIODIC' AS string)         AS report_tp_code,
        CAST(sc_periodic_rpt_id AS string) AS report_id,
        rpt_submission_status_code,
        CAST(sent_tms AS date)              AS sent_dt,
        submission_deadline_dt,
        rpt_year,
        rpt_period                          AS rpt_period_tp_code,
        period                               AS period_nbr,
        CAST(NULL AS string)                AS period_val,
        CAST(NULL AS date)                  AS created_dt,
        src_stm_code,
        rpt_nm
    FROM {{ ref('atm_sc_periodic_report') }}
    WHERE src_stm_code = 'SCMS_SC_FIRM_PERIODIC_REPORT'
),

all_rpt AS (
    SELECT * FROM adhoc_rpt
    UNION ALL
    SELECT * FROM periodic_rpt
)

SELECT
    CAST(cd_dt_di.cdr_dt_dim_id AS string)             AS snpst_dt_dim_id,
    CAST(se_co_di.securities_company_dim_id AS string) AS securities_company_dim_id,
    CAST(all_rpt.report_tp_code AS string)             AS report_tp_code,
    CAST(all_rpt.report_id AS string)                  AS report_id,
    CAST(all_rpt.rpt_submission_status_code AS string) AS rpt_submission_status_code,
    CAST(all_rpt.sent_dt AS date)                      AS sent_dt,
    CAST(all_rpt.submission_deadline_dt AS date)       AS submission_deadline_dt,
    CAST(all_rpt.rpt_year AS int)                      AS rpt_year,
    CAST(all_rpt.rpt_period_tp_code AS string)         AS rpt_period_tp_code,
    CAST(all_rpt.period_nbr AS int)                    AS period_nbr,
    CAST(all_rpt.period_val AS string)                 AS period_val,
    CAST(all_rpt.created_dt AS date)                   AS created_dt,
    CAST(all_rpt.src_stm_code AS string)               AS src_stm_code,
    CAST(all_rpt.rpt_nm AS string)                     AS rpt_nm
FROM all_rpt
CROSS JOIN cd_dt_di
LEFT JOIN se_co_di
    ON  se_co_di.sc_code = all_rpt.sc_code
