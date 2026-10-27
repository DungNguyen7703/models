/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_investment_fund_profile
* Program name: Dtm Opr Investment Fund Profile
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-28		claude (draft)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_opr_investment_fund_profile_FMS_FUNDS.csv
*                                       CHƯA CÓ model atm_cl_fms_position, atm_fmc_employee -> enabled: false
*                                       LLD fmc_employee_x_investment_fund_relationship -> ref atm_investment_fund_x_fmc_employee_relationship
*                                       Subquery tương quan (LLD) -> CTE aggregate theo investment_fund_id + LEFT JOIN
* 2026-09-29		claude (draft)		Đổi nguồn atm_* sang bảng Dim QLQ tương ứng (dtm_*_dim_hstr) cho các entity đã có Dim
* 2026-10-07		claude (sync)		Đồng bộ LLD theo Atomic FMS UAT 20261006 (commit 117654ae, 53443cc1): representative_board_member_count: JOIN cl_fms_job (thay cl_fms_position), bỏ filter active_status_flag;
*                                       manager_count: qua fmc_employee_x_classification_fms_position_relationship + cl_fms_job
*                                       (thay fmc_employee.job_tp_code); fund_tp_code của Dim nay = cl_fms_fund_tp_code;
*                                       CHƯA CÓ model atm_cl_fms_job -> giữ enabled: false
* 2026-10-07		claude				Đổi ref sang atm_fmc_employee_x_investment_fund_relationship, atm_fmc_employee_x_classification_fms_job_relationship
*										(Atomic đổi tên theo LLD); cl_fms_position_code -> cl_fms_job_code
* 2026-10-10		claude				outstanding_unit_quantity int -> bigint theo LLD sửa 2026-10-08 (commit 216a6491, tránh tràn số âm) (schema-changing:
*                                       Iceberg cần ALTER COLUMN ... TYPE bigint trên bảng chính + _hstr trước khi chạy)
* 2026-10-14		claude (sync)		Đồng bộ LLD commit 2f62880d: thêm distribution_agent_count, net_asset_val_amt, year_to_dt_profit_amt.
*                                       distribution_agent_count: atm_fund_distribution_agent_x_investment_fund_x_cl_fms_agency_type_relationship
*                                       (scd2, src FMS_FUD_AG_AGT) INNER JOIN atm_cl_fms_agency_type (scd2, src FMS_AGENCY_TYPE, tên loại
*                                       LIKE '%đại lý phân phối%'); subquery tương quan -> CTE aggregate; id Atomic bigint -> CAST string để join Dim.
*                                       NAV/lợi nhuận lũy kế: atm_fmr_value (record_tp '7') + atm_fmr_submission + dtm_fund_management_rpt_cell_dim_hstr,
*                                       FETCH FIRST 1 ROW -> ROW_NUMBER (tie-breaker fmr_val_code DESC thêm), TO_NUMBER -> try_cast (schema-changing)
* 2026-10-14		claude (sync)		Đồng bộ LLD commit d18cdaa0 (ETL date bound): KPI báo cáo định kỳ chỉ xét bản nộp có
*                                       fmr_submission.submitted_dt <= etl_date (lọc trong CTE fmr_submission)
* 2026-10-19		claude (sync)		Đồng bộ LLD commit 2c7dd4b1 (O_QLQ_30): manager_count = COUNT(DISTINCT fmc_employee_id)
*                                       atm_fmc_employee_x_investment_fund_relationship INNER JOIN atm_fmc_employee_hstr (FMS_TL_PROFILES);
*                                       bỏ atm_fmc_employee_x_classification_fms_job_relationship (Atomic đã xóa JOB_TL_PRO)
*                                       và filter cl_fms_job_nm = 'ban điều hành'
* 2026-10-19		claude (sync)		Đồng bộ LLD commit b59825e3 (O_QLQ_40): representative_board_member_count lọc theo
*                                       LOẠI chức danh: cl_fms_job (FMS_JOBS) nối dòng cl_fms_job (FMS_JOB_TYPE) qua
*                                       cl_fms_job_tp_code, LOWER(job_tp_nm) = 'ban đại diện' (thay cl_fms_job_nm).
*                                       LƯU Ý: atm_cl_fms_job hiện chỉ sinh dòng FMS_JOBS (denormalize job_tp_nm) —
*                                       count = 0 cho tới khi Atomic bổ sung dòng FMS_JOB_TYPE theo lld_FMS_JOB_TYPE.yaml
* 2026-10-24		claude (sync)		Đồng bộ LLD commit 576f001c: KPI báo cáo định kỳ lọc record_tp = '7' theo fmr_submission (RPT_MEMBER) thay cho
*                                       fmr_value, thêm record_status_code IN ('2','3','5','10'); nối bản nộp -> investment_fund theo investment_fund_id
*                                       (thay investment_fund_code — khớp PK dim theo luật A23) (logic-only, schema không đổi)
* 2026-10-24		claude (sync)		Đồng bộ LLD commit 7164d9ca (schema-changing): bỏ fmc_short_nm; thêm investment_fund_short_nm,
*                                       fmc_full_nm (Dim fmc, giữ LEFT JOIN). Lọc dòng: chỉ quỹ có giấy phép thành lập và hoạt động
*                                       (atm_ip_alternative_identification FMS_FUNDS, ESTABLISHMENT_OPERATION_LICENSE, issue_dt <= etl_date) —
*                                       EXISTS (LLD) -> INNER JOIN CTE DISTINCT ip_id như dtm_fct_investment_fund_ccq_snpst.
*                                       NAV chỉ xét bản nộp kỳ tháng (period_tp_code = '3'); NAV + LN lũy kế ORDER BY fmr_submission.rpt_year DESC,
*                                       period_month_no DESC, period_tp_code DESC, submitted_dt DESC, fmr_val_code DESC (tie-breaker giữ)
*--------------------------------------------------------------------*
*/

WITH establishment_license AS (
    SELECT DISTINCT
        ip_id
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
        AND identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'
        AND identification_issue_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

investment_fund AS (
    SELECT
        investment_fund_id,
        investment_fund_code,
        investment_fund_full_nm,
        investment_fund_short_nm,
        fund_tp_code,
        fmc_id,
        custodian_bank_id,
        total_outstanding_unit_quantity,
        src_stm_code
    FROM {{ ref('dtm_investment_fund_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
),

fund_management_company AS (
    SELECT
        fmc_id,
        fmc_full_nm
    FROM {{ ref('dtm_fund_management_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SECURITIES'
),

custodian_bank AS (
    SELECT
        custodian_bank_id,
        custodian_bank_full_nm
    FROM {{ ref('dtm_custodian_bank_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_BANK_MONI'
),

representative_board_member AS (
    SELECT
        investment_fund_id,
        cl_fms_job_code
    FROM {{ ref('atm_investment_fund_representative_board_member') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_REPRESENT'
),

cl_fms_job AS (
    SELECT
        cl_fms_job_code,
        cl_fms_job_tp_code
    FROM {{ ref('atm_cl_fms_job') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND ds_rcrd_end_dt = to_date('2400-01-01')
        AND src_stm_code = 'FMS_JOBS'
),

cl_fms_job_type AS (
    SELECT
        cl_fms_job_code,
        job_tp_nm
    FROM {{ ref('atm_cl_fms_job') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND ds_rcrd_end_dt = to_date('2400-01-01')
        AND src_stm_code = 'FMS_JOB_TYPE'
),

fmc_employee AS (
    SELECT
        fmc_employee_id
    FROM {{ ref('atm_fmc_employee') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_TL_PROFILES'
),

fmc_employee_x_investment_fund_relationship AS (
    SELECT
        investment_fund_id,
        fmc_employee_id
    FROM {{ ref('atm_fmc_employee_x_investment_fund_relationship') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUND_TL_PRO'
),

board_agg AS (
    SELECT
        rbm.investment_fund_id,
        COUNT(*) AS representative_board_member_count
    FROM representative_board_member rbm
    INNER JOIN cl_fms_job
        ON cl_fms_job.cl_fms_job_code = rbm.cl_fms_job_code
    INNER JOIN cl_fms_job_type jt
        ON jt.cl_fms_job_code = cl_fms_job.cl_fms_job_tp_code
    WHERE LOWER(jt.job_tp_nm) = 'ban đại diện'
    GROUP BY rbm.investment_fund_id
),

manager_agg AS (
    SELECT
        rltnp.investment_fund_id,
        COUNT(DISTINCT rltnp.fmc_employee_id) AS manager_count
    FROM fmc_employee_x_investment_fund_relationship rltnp
    INNER JOIN fmc_employee
        ON fmc_employee.fmc_employee_id = rltnp.fmc_employee_id
    GROUP BY rltnp.investment_fund_id
),

cl_fms_agency_type AS (
    SELECT
        cl_fms_agency_tp_id,
        cl_fms_agency_tp_nm
    FROM {{ ref('atm_cl_fms_agency_type') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND ds_rcrd_end_dt = to_date('2400-01-01')
        AND src_stm_code = 'FMS_AGENCY_TYPE'
),

fund_distribution_agent_x_investment_fund_x_cl_fms_agency_type_relationship AS (
    SELECT
        investment_fund_id,
        fund_distribution_agent_id,
        cl_fms_agency_tp_id
    FROM {{ ref('atm_fund_distribution_agent_x_investment_fund_x_cl_fms_agency_type_relationship') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND ds_rcrd_end_dt = to_date('2400-01-01')
        AND src_stm_code = 'FMS_FUD_AG_AGT'
),

distribution_agent_agg AS (
    SELECT
        CAST(rltnp.investment_fund_id AS string)                                AS investment_fund_id,
        COUNT(DISTINCT rltnp.fund_distribution_agent_id)                        AS distribution_agent_count
    FROM fund_distribution_agent_x_investment_fund_x_cl_fms_agency_type_relationship rltnp
    INNER JOIN cl_fms_agency_type
        ON cl_fms_agency_type.cl_fms_agency_tp_id = rltnp.cl_fms_agency_tp_id
    WHERE lower(cl_fms_agency_type.cl_fms_agency_tp_nm) LIKE '%đại lý phân phối%'
    GROUP BY CAST(rltnp.investment_fund_id AS string)
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
        period_tp_code,
        period_val,
        rpt_year,
        submitted_dt
    FROM {{ ref('atm_fmr_submission') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_RPT_MEMBER'
        AND record_tp = '7'
        AND record_status_code IN ('2','3','5','10')
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
            WHEN cell.fmr_sheet_nm IN ('BCKetQuaHoatDongKinhDoanh', 'BCThuNhap_06203')
                AND cell.row_indicator_code IN ('41', '50')
                AND LOWER(cell.column_label_nm) LIKE '%lũy kế từ đầu năm đến cuối kỳ báo cáo%'
                THEN 'year_to_dt_profit_amt'
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
        MAX(CASE WHEN kpi_code = 'net_asset_val_amt' THEN cell_numeric_val END) AS net_asset_val_amt,
        MAX(CASE WHEN kpi_code = 'year_to_dt_profit_amt' THEN cell_numeric_val END) AS year_to_dt_profit_amt
    FROM (
        SELECT
            investment_fund_id,
            kpi_code,
            cell_numeric_val,
            ROW_NUMBER() OVER (PARTITION BY investment_fund_id, kpi_code
                               ORDER BY rpt_year DESC, period_month_no DESC, period_tp_code DESC, submitted_dt DESC, fmr_val_code DESC) AS rn
        FROM rpt_cell_val
        WHERE kpi_code IS NOT NULL
            AND (kpi_code <> 'net_asset_val_amt' OR period_tp_code = '3')
    ) t
    WHERE rn = 1
    GROUP BY investment_fund_id
)

SELECT
    CAST(investment_fund.investment_fund_code AS string)                                        AS investment_fund_code
    , CAST(investment_fund.investment_fund_full_nm AS string)                                   AS investment_fund_full_nm
    , CAST(investment_fund.investment_fund_short_nm AS string)                                  AS investment_fund_short_nm
    , CAST(investment_fund.fund_tp_code AS string)                                              AS fund_tp_code
    , CAST(fund_management_company.fmc_full_nm AS string)                                       AS fmc_full_nm
    , CAST(custodian_bank.custodian_bank_full_nm AS string)                                     AS custodian_bank_full_nm
    , CAST(COALESCE(board_agg.representative_board_member_count, 0) AS int)                     AS representative_board_member_count
    , CAST(COALESCE(manager_agg.manager_count, 0) AS int)                                       AS manager_count
    , CAST(investment_fund.total_outstanding_unit_quantity AS bigint)                           AS outstanding_unit_quantity
    , CAST(COALESCE(distribution_agent_agg.distribution_agent_count, 0) AS int)                 AS distribution_agent_count
    , CAST(rpt_kpi.net_asset_val_amt AS decimal(23,2))                                          AS net_asset_val_amt
    , CAST(rpt_kpi.year_to_dt_profit_amt AS decimal(23,2))                                      AS year_to_dt_profit_amt
    , CAST(investment_fund.src_stm_code AS string)                                              AS src_stm_code
FROM investment_fund
INNER JOIN establishment_license
    ON establishment_license.ip_id = investment_fund.investment_fund_id
LEFT JOIN fund_management_company
    ON fund_management_company.fmc_id = investment_fund.fmc_id
LEFT JOIN custodian_bank
    ON custodian_bank.custodian_bank_id = investment_fund.custodian_bank_id
LEFT JOIN board_agg
    ON board_agg.investment_fund_id = investment_fund.investment_fund_id
LEFT JOIN manager_agg
    ON manager_agg.investment_fund_id = investment_fund.investment_fund_id
LEFT JOIN distribution_agent_agg
    ON distribution_agent_agg.investment_fund_id = investment_fund.investment_fund_id
LEFT JOIN rpt_kpi
    ON rpt_kpi.investment_fund_id = investment_fund.investment_fund_id
