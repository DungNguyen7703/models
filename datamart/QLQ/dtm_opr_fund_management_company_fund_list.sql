/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_fund_management_company_fund_list
* Program name: Dtm Opr Fund Management Company Fund List
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-28		claude (draft)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_opr_fund_management_company_fund_list_FMS_FUNDS.csv
* 2026-09-29		claude (draft)		Đổi nguồn atm_* sang bảng Dim QLQ tương ứng (dtm_*_dim_hstr) cho các entity đã có Dim
* 2026-10-07		claude (sync)		Đồng bộ LLD theo Atomic FMS UAT 20261006 (commit 117654ae, 53443cc1): fund_tp_code của Dim nay = cl_fms_fund_tp_code; bỏ net_asset_val_amt (LLD đã bỏ)
* 2026-10-14		claude (sync)		Đồng bộ LLD commit 2f62880d: thêm lại net_asset_val_amt (NAV kỳ mới nhất) — atm_fmr_value (src FMS_RPT_VALUES,
*                                       record_tp '7') + atm_fmr_submission (src FMS_RPT_MEMBER) + dtm_fund_management_rpt_cell_dim_hstr.
*                                       FETCH FIRST 1 ROW (LLD) -> ROW_NUMBER theo investment_fund_code ORDER BY rpt_year DESC, period_val DESC,
*                                       submitted_dt DESC, fmr_val_code DESC (tie-breaker thêm). TO_NUMBER -> try_cast (schema-changing)
* 2026-10-14		claude (sync)		Đồng bộ LLD commit d18cdaa0 (ETL date bound): KPI báo cáo định kỳ chỉ xét bản nộp có
*                                       fmr_submission.submitted_dt <= etl_date (lọc trong CTE fmr_submission)
* 2026-10-24		claude (sync)		Đồng bộ LLD commit 576f001c: KPI báo cáo định kỳ lọc record_tp = '7' theo fmr_submission (RPT_MEMBER) thay cho
*                                       fmr_value, thêm record_status_code IN ('2','3','5','10'); nối bản nộp -> investment_fund theo investment_fund_id
*                                       (thay investment_fund_code — khớp PK dim theo luật A23) (logic-only, schema không đổi)
* 2026-10-24		claude (sync)		Đồng bộ LLD commit 7164d9ca: net_asset_val_amt chỉ lấy kỳ tháng (period_tp_code = '3', lọc trong
*                                       CTE fmr_submission — bảng chỉ có 1 KPI báo cáo); chọn kỳ mới nhất theo rpt_year/period_val/period_tp_code
*                                       của fmr_submission thay fmr_value (logic-only, schema không đổi)
*--------------------------------------------------------------------*
*/

WITH investment_fund AS (
    SELECT
        investment_fund_id,
        investment_fund_code,
        fmc_id,
        fmc_code,
        investment_fund_full_nm,
        fund_tp_code,
        src_stm_code
    FROM {{ ref('dtm_investment_fund_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
),

fmr_value AS (
    SELECT
        fmr_val_code,
        fmr_submission_id,
        fmr_sheet_code,
        cell_id,
        rpt_year,
        period_val,
        cell_val
    FROM {{ ref('atm_fmr_value') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_RPT_VALUES'
),

fmr_submission AS (
    SELECT
        fmr_submission_id,
        investment_fund_id,
        submitted_dt,
        period_tp_code,
        period_val,
        rpt_year
    FROM {{ ref('atm_fmr_submission') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_RPT_MEMBER'
        AND record_tp = '7'
        AND record_status_code IN ('2','3','5','10')
        AND period_tp_code = '3'
        AND submitted_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

fund_management_rpt_cell AS (
    SELECT
        fmr_sheet_code,
        cell_id,
        fmr_nm,
        fmr_sheet_nm,
        row_indicator_code,
        column_label_nm
    FROM {{ ref('dtm_fund_management_rpt_cell_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SHEET'
),

rpt_cell_val AS (
    SELECT
        fmr_submission.investment_fund_id,
        CASE
            WHEN cell.fmr_sheet_nm LIKE '%BCTaiSan%' AND LOWER(cell.fmr_nm) LIKE '%hoạt động%'
                AND cell.row_indicator_code = '2217' AND cell.column_label_nm = 'Kỳ báo cáo'
                THEN 'net_asset_val_amt'
        END                                                                             AS kpi_code,
        try_cast(regexp_replace(CAST(fmr_value.cell_val AS string), '%', '') AS decimal(38,8)) AS cell_numeric_val,
        fmr_submission.rpt_year,
        CASE fmr_submission.period_tp_code
            WHEN '3' THEN CAST(COALESCE(NULLIF(REGEXP_EXTRACT(fmr_submission.period_val, '^T(\\d{2})/', 1), ''), fmr_submission.period_val) AS INT)
            WHEN '4' THEN 3 * CAST(COALESCE(NULLIF(REGEXP_EXTRACT(fmr_submission.period_val, '^Q(\\d)/', 1), ''), fmr_submission.period_val) AS INT)
            WHEN '5' THEN 6
            WHEN '6' THEN 12
        END                                                                             AS period_month_no,
        fmr_submission.period_tp_code,
        fmr_submission.submitted_dt,
        fmr_value.fmr_val_code
    FROM fmr_value
    INNER JOIN fmr_submission
        ON fmr_submission.fmr_submission_id = fmr_value.fmr_submission_id
    INNER JOIN fund_management_rpt_cell cell
        ON cell.fmr_sheet_code = fmr_value.fmr_sheet_code
        AND cell.cell_id = fmr_value.cell_id
),

rpt_kpi AS (
    SELECT
        investment_fund_id,
        MAX(CASE WHEN kpi_code = 'net_asset_val_amt' THEN cell_numeric_val END) AS net_asset_val_amt
    FROM (
        SELECT
            investment_fund_id,
            kpi_code,
            cell_numeric_val,
            ROW_NUMBER() OVER (PARTITION BY investment_fund_id, kpi_code
                               ORDER BY rpt_year DESC, period_month_no DESC, period_tp_code DESC,
                                        submitted_dt DESC, fmr_val_code DESC) AS rn
        FROM rpt_cell_val
        WHERE kpi_code IS NOT NULL
    ) t
    WHERE rn = 1
    GROUP BY investment_fund_id
)

SELECT
    CAST(investment_fund.investment_fund_code AS string)                        AS investment_fund_code
    , CAST(investment_fund.fmc_id AS string)                                    AS fmc_id
    , CAST(investment_fund.fmc_code AS string)                                  AS fmc_code
    , CAST(investment_fund.investment_fund_full_nm AS string)                   AS investment_fund_full_nm
    , CAST(investment_fund.fund_tp_code AS string)                              AS fund_tp_code
    , CAST(rpt_kpi.net_asset_val_amt AS decimal(23,2))                          AS net_asset_val_amt
    , CAST(investment_fund.src_stm_code AS string)                              AS src_stm_code
FROM investment_fund
LEFT JOIN rpt_kpi
    ON rpt_kpi.investment_fund_id = investment_fund.investment_fund_id
