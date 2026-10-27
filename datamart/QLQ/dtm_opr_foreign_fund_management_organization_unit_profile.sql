/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_foreign_fund_management_organization_unit_profile
* Program name: Dtm Opr Foreign Fund Management Organization Unit Profile
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-28		claude (draft)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_opr_foreign_fund_management_organization_unit_profile_FMS_FOR_BRCH.csv
*                                       LLD atomic_table = foreign_fm_ou -> ref atm_foreign_fund_management_organization_unit
*                                       director_full_nm: dedupe ROW_NUMBER (1 Giám đốc/CN) tránh nhân bản PK khi nguồn có >1 dòng branch_director_flag = 1
* 2026-09-29		claude (draft)		Đổi nguồn atm_* sang bảng Dim QLQ tương ứng (dtm_*_dim_hstr) cho các entity đã có Dim
* 2026-10-14		claude (sync)		Đồng bộ LLD commit 2f62880d: thêm 5 KPI báo cáo định kỳ — certified_practitioner_staff_count, capital_adequacy_ratio,
*                                       net_profit_after_tax_amt, owner_equity_amt, portfolio_management_contract_count.
*                                       Nguồn atm_fmr_value (src FMS_RPT_VALUES, record_tp '4') + atm_fmr_submission (src FMS_RPT_MEMBER)
*                                       + dtm_fund_management_rpt_cell_dim_hstr. Subquery FETCH FIRST 1 ROW (LLD) -> CASE kpi_code + ROW_NUMBER
*                                       theo (foreign_fm_ou_code, kpi_code) ORDER BY rpt_year DESC, period_val DESC, submitted_dt DESC,
*                                       fmr_val_code DESC (tie-breaker thêm) + pivot MAX(CASE). TO_NUMBER -> try_cast (schema-changing)
* 2026-10-14		claude (sync)		Đồng bộ LLD commit d18cdaa0 (ETL date bound): KPI báo cáo định kỳ chỉ xét bản nộp có
*                                       fmr_submission.submitted_dt <= etl_date (lọc trong CTE fmr_submission)
* 2026-10-24		claude (sync)		Đồng bộ LLD commit 576f001c: KPI báo cáo định kỳ lọc record_tp = '4' theo fmr_submission (RPT_MEMBER) thay cho
*                                       fmr_value, thêm record_status_code IN ('2','3','5','10'); nối bản nộp -> foreign_fm_ou theo foreign_fm_ou_id
*                                       (thay foreign_fm_ou_code — khớp PK dim theo luật A23) (logic-only, schema không đổi)
* 2026-10-24		claude (sync)		Đồng bộ LLD commit 7164d9ca: bộ lọc dòng — chỉ Chi nhánh (branch_tp_code = '1') có
*                                       COALESCE(effective_start_dt, MIN ngày cấp ESTABLISHMENT_OPERATION_LICENSE src FMS_FOR_BRCH) <= etl_date;
*                                       KPI báo cáo định kỳ: certified_practitioner/capital_adequacy/portfolio_contract chỉ lấy kỳ tháng
*                                       (period_tp_code = '3'); chọn kỳ mới nhất theo rpt_year/period_val/period_tp_code của fmr_submission
*                                       (logic-only, schema không đổi)
*--------------------------------------------------------------------*
*/

WITH establishment_license AS (
    SELECT
        ip_id,
        MIN(identification_issue_dt) AS identification_issue_dt
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FOR_BRCH'
        AND identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'
    GROUP BY ip_id
),

foreign_fm_ou AS (
    SELECT
        foreign_fm_ou.foreign_fund_management_organization_unit_id AS foreign_fm_ou_id,
        foreign_fm_ou.foreign_fund_management_organization_unit_code AS foreign_fm_ou_code,
        foreign_fm_ou.foreign_fund_management_organization_unit_full_nm AS foreign_fm_ou_full_nm,
        foreign_fm_ou.foreign_fund_management_organization_unit_short_nm AS foreign_fm_ou_short_nm,
        foreign_fm_ou.src_stm_code
    FROM {{ ref('dtm_foreign_fund_management_organization_unit_dim') }}_hstr foreign_fm_ou
    LEFT JOIN establishment_license
        ON establishment_license.ip_id = foreign_fm_ou.foreign_fund_management_organization_unit_id
    WHERE foreign_fm_ou.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND foreign_fm_ou.ds_rcrd_st = 'ACTIVE'
        AND foreign_fm_ou.src_stm_code = 'FMS_FOR_BRCH'
        AND foreign_fm_ou.branch_tp_code = '1'
        AND COALESCE(foreign_fm_ou.effective_start_dt, establishment_license.identification_issue_dt)
            <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

foreign_fm_ou_staff AS (
    SELECT
        foreign_fund_management_organization_unit_id AS foreign_fm_ou_id,
        foreign_fund_management_organization_unit_staff_code AS foreign_fm_ou_staff_code,
        foreign_fund_management_organization_unit_staff_full_nm AS foreign_fm_ou_staff_full_nm,
        branch_director_flag
    FROM {{ ref('dtm_foreign_fund_management_organization_unit_staff_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_STF_FG_BRCH'
),

director AS (
    SELECT
        foreign_fm_ou_id,
        foreign_fm_ou_staff_full_nm
    FROM (
        SELECT
            foreign_fm_ou_staff.foreign_fm_ou_id,
            foreign_fm_ou_staff.foreign_fm_ou_staff_full_nm,
            ROW_NUMBER() OVER (PARTITION BY foreign_fm_ou_staff.foreign_fm_ou_id
                               ORDER BY foreign_fm_ou_staff.foreign_fm_ou_staff_code) AS rn
        FROM foreign_fm_ou_staff
        WHERE foreign_fm_ou_staff.branch_director_flag = 1
    ) t
    WHERE rn = 1
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
        foreign_fm_ou_id,
        submitted_dt,
        period_tp_code,
        period_val,
        rpt_year
    FROM {{ ref('atm_fmr_submission') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_RPT_MEMBER'
        AND record_tp = '4'
        AND record_status_code IN ('2','3','5','10')
        AND submitted_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

fund_management_rpt_cell AS (
    SELECT
        fmr_sheet_code,
        cell_id,
        fmr_nm,
        fmr_sheet_nm,
        row_indicator_nm,
        column_label_nm
    FROM {{ ref('dtm_fund_management_rpt_cell_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SHEET'
),

rpt_cell_val AS (
    SELECT
        fmr_submission.foreign_fm_ou_id,
        CASE
            WHEN cell.fmr_sheet_nm = 'II. Các thông tin liên quan nhân sự của chi nhánh'
                AND cell.row_indicator_nm = 'Số nhân viên có Chứng chỉ hành nghề, Chứng chỉ quốc tế (nêu rõ loại hình)'
                AND cell.column_label_nm = 'Kỳ báo cáo'
                AND fmr_submission.period_tp_code = '3'
                THEN 'certified_practitioner_staff_count'
            WHEN cell.fmr_sheet_nm = 'BangTongHop_06013' AND LOWER(cell.fmr_nm) LIKE '%tỷ lệ an toàn%'
                AND LOWER(cell.row_indicator_nm) LIKE '%tỷ lệ vốn khả dụng%' AND cell.column_label_nm = 'Giá trị rủi ro/vốn khả dụng'
                AND fmr_submission.period_tp_code = '3'
                THEN 'capital_adequacy_ratio'
            WHEN cell.fmr_sheet_nm = 'BCKetQuaHoatDongKinhDoanh' AND LOWER(cell.fmr_nm) LIKE '%báo cáo tài chính%'
                AND LOWER(cell.row_indicator_nm) LIKE '%lợi nhuận sau thuế%' AND cell.column_label_nm = 'Kỳ này'
                THEN 'net_profit_after_tax_amt'
            WHEN cell.fmr_sheet_nm = 'BangCanDoiKeToan' AND LOWER(cell.fmr_nm) LIKE '%báo cáo tài chính%'
                AND LOWER(cell.row_indicator_nm) LIKE '%vốn chủ sở hữu%' AND cell.column_label_nm = 'Số cuối kỳ'
                THEN 'owner_equity_amt'
            WHEN cell.fmr_sheet_nm = 'I. Thông tin chung về tình hình quản lý danh mục đầu tư' AND LOWER(cell.fmr_nm) LIKE '%danh mục đầu tư%'
                AND LOWER(cell.row_indicator_nm) LIKE '%số hợp đồng ủy thác%' AND cell.column_label_nm = 'Kỳ báo cáo'
                AND fmr_submission.period_tp_code = '3'
                THEN 'portfolio_management_contract_count'
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
        foreign_fm_ou_id,
        MAX(CASE WHEN kpi_code = 'certified_practitioner_staff_count'  THEN cell_numeric_val END) AS certified_practitioner_staff_count,
        MAX(CASE WHEN kpi_code = 'capital_adequacy_ratio'              THEN cell_numeric_val END) AS capital_adequacy_ratio,
        MAX(CASE WHEN kpi_code = 'net_profit_after_tax_amt'            THEN cell_numeric_val END) AS net_profit_after_tax_amt,
        MAX(CASE WHEN kpi_code = 'owner_equity_amt'                    THEN cell_numeric_val END) AS owner_equity_amt,
        MAX(CASE WHEN kpi_code = 'portfolio_management_contract_count' THEN cell_numeric_val END) AS portfolio_management_contract_count
    FROM (
        SELECT
            foreign_fm_ou_id,
            kpi_code,
            cell_numeric_val,
            ROW_NUMBER() OVER (PARTITION BY foreign_fm_ou_id, kpi_code
                               ORDER BY rpt_year DESC, period_month_no DESC, period_tp_code DESC,
                                        submitted_dt DESC, fmr_val_code DESC) AS rn
        FROM rpt_cell_val
        WHERE kpi_code IS NOT NULL
    ) t
    WHERE rn = 1
    GROUP BY foreign_fm_ou_id
)

SELECT
    CAST(foreign_fm_ou.foreign_fm_ou_code AS string)                                            AS foreign_fund_management_organization_unit_code
    , CAST(foreign_fm_ou.foreign_fm_ou_full_nm AS string)                                       AS foreign_fund_management_organization_unit_full_nm
    , CAST(foreign_fm_ou.foreign_fm_ou_short_nm AS string)                                      AS foreign_fund_management_organization_unit_short_nm
    , CAST(director.foreign_fm_ou_staff_full_nm AS string)                                      AS director_full_nm
    , CAST(rpt_kpi.certified_practitioner_staff_count AS int)                                   AS certified_practitioner_staff_count
    , CAST(rpt_kpi.capital_adequacy_ratio AS decimal(9,2))                                      AS capital_adequacy_ratio
    , CAST(rpt_kpi.net_profit_after_tax_amt AS decimal(23,2))                                   AS net_profit_after_tax_amt
    , CAST(rpt_kpi.owner_equity_amt AS decimal(23,2))                                           AS owner_equity_amt
    , CAST(rpt_kpi.portfolio_management_contract_count AS int)                                  AS portfolio_management_contract_count
    , CAST(foreign_fm_ou.src_stm_code AS string)                                                AS src_stm_code
FROM foreign_fm_ou
LEFT JOIN director
    ON director.foreign_fm_ou_id = foreign_fm_ou.foreign_fm_ou_id
LEFT JOIN rpt_kpi
    ON rpt_kpi.foreign_fm_ou_id = foreign_fm_ou.foreign_fm_ou_id
