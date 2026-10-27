/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_fund_management_company_profile
* Program name: Dtm Opr Fund Management Company Profile
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-28		claude (draft)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_opr_fund_management_company_profile_FMS_SECURITIES.csv
*                                       CHƯA CÓ model atm_member_rating, atm_discretionary_investment_account -> enabled: false
*                                       Subquery tương quan (LLD) -> CTE aggregate theo fmc_id + LEFT JOIN
*                                       member_rating MAX(data_dt) <= etl_date -> ROW_NUMBER; LLD không nêu src_stm_code
*                                       cho member_rating nên không filter src
* 2026-09-29		claude (draft)		Đổi nguồn atm_* sang bảng Dim QLQ tương ứng (dtm_*_dim_hstr) cho các entity đã có Dim
* 2026-10-07		claude (sync)		Đồng bộ LLD theo Atomic FMS UAT 20261006 (commit 117654ae, 53443cc1): member_rating: kỳ mới nhất theo member_rating_period.rating_data_update_dt <= etl_date
*                                       (JOIN member_rating_period_code = member_rating.m_ember_rating_period_code, tên cột theo LLD);
*                                       bỏ discretionary_investment_account_count (LLD đã bỏ)
* 2026-10-07		claude				m_ember_rating_period_code -> member_rating_period_code (model atm_member_rating dung ten dung chinh ta)
* 2026-10-14		claude (sync)		Đồng bộ LLD commit 2f62880d: thêm 6 KPI báo cáo định kỳ (K_QLQ_22, 27, 29..32) — certified_practitioner_staff_count,
*                                       assets_under_management_amt, capital_adequacy_ratio, net_profit_after_tax_amt, owner_equity_amt,
*                                       portfolio_management_contract_count. Nguồn atm_fmr_value (src FMS_RPT_VALUES, record_tp '2')
*                                       + atm_fmr_submission (src FMS_RPT_MEMBER) + dtm_fund_management_rpt_cell_dim_hstr.
*                                       Subquery FETCH FIRST 1 ROW (LLD) -> gán kpi_code bằng CASE + ROW_NUMBER theo (fmc_code, kpi_code)
*                                       ORDER BY rpt_year DESC, period_val DESC, submitted_dt DESC, fmr_val_code DESC (tie-breaker thêm)
*                                       + pivot MAX(CASE). TO_NUMBER(... DEFAULT NULL ON CONVERSION ERROR) -> try_cast (schema-changing)
* 2026-10-14		claude (sync)		Đồng bộ LLD commit d18cdaa0 (ETL date bound): KPI báo cáo định kỳ chỉ xét bản nộp có
*                                       fmr_submission.submitted_dt <= etl_date (lọc trong CTE fmr_submission)
* 2026-10-24		claude (sync)		Đồng bộ LLD commit 576f001c: member_rating lấy kỳ mới nhất theo member_rating_period.rpt_year DESC,
*                                       rating_period_tp_code ('0' = cả năm ưu tiên hơn kỳ khác), rpt_year <= YEAR(etl_date)
*                                       (thay rating_data_update_dt); record_tp = '2' chuyển từ fmr_value sang fmr_submission
*                                       + thêm record_status_code IN ('2','3','5','10').
*                                       LLD inline lại logic row_code/col_label từ fmr_sheet: GIỮ lookup dtm_fund_management_rpt_cell_dim
*                                       (cùng công thức row_indicator_code/column_label_nm, HLD vẫn ghi lookup Dim); giữ các bộ lọc ô đã chỉnh tay
* 2026-10-24		claude (sync)		Đồng bộ LLD commit 7164d9ca: bỏ rank_index; thêm operation_status_nm (LEFT JOIN atm_cl_fms_status
*                                       theo Dim operation_status_code = cl_fms_status_code, như dtm_fct_fund_management_company_snpst),
*                                       legal_representative_nm (director_full_nm khi legal_representative_ind = '1'), rating_class_code
*                                       (= member_rating.rating_period_tp_code theo LLD). member_rating: kỳ mới nhất theo ngày cuối kỳ
*                                       (tp '1' -> 30/06, khác -> 31/12) <= etl_date, rating_finalized_flag DESC, total_score_amt DESC.
*                                       KPI báo cáo: bctc_ind (net_profit/owner_equity = 1); bctc_ind 0 chỉ xét kỳ tháng (period_tp_code '3'),
*                                       bctc_ind 1 chỉ xét quý/bán niên/năm có period_end_dt <= etl_date; ORDER BY period_end_dt DESC,
*                                       period_tp_code DESC, tpl_version (Dim rpt_cell version_nbr) DESC, BC kiểm toán/soát xét trước,
*                                       submitted_dt DESC, fmr_val_code DESC (tie-breaker giữ). Vẫn GIỮ lookup Dim rpt_cell + bộ lọc ô chỉnh tay
*--------------------------------------------------------------------*
*/

WITH fund_management_company AS (
    SELECT
        fmc_id,
        fmc_code,
        fmc_full_nm,
        fmc_short_nm,
        operation_status_code,
        legal_representative_ind,
        director_full_nm,
        charter_capital_amt,
        src_stm_code
    FROM {{ ref('dtm_fund_management_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SECURITIES'
),

cl_fms_status AS (
    SELECT
        cl_fms_status_code,
        cl_fms_status_nm
    FROM {{ ref('atm_cl_fms_status') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_STATUS'
),

investment_fund AS (
    SELECT
        investment_fund_id,
        fmc_id
    FROM {{ ref('dtm_investment_fund_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
),

member_rating_period AS (
    SELECT
        member_rating_period_code,
        rpt_year,
        rating_period_tp_code,
        rating_finalized_flag,
        CASE rating_period_tp_code
            WHEN '1' THEN MAKE_DATE(rpt_year, 6, 30)
            ELSE MAKE_DATE(rpt_year, 12, 31)
        END AS rating_period_end_dt
    FROM {{ ref('atm_member_rating_period') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

member_rating AS (
    SELECT
        fmc_id,
        rating_class_code,
        total_score_amt
    FROM (
        SELECT
            mr.fmc_id,
            mr.rating_period_tp_code AS rating_class_code,
            mr.total_score_amt,
            ROW_NUMBER() OVER (PARTITION BY mr.fmc_id
                               ORDER BY member_rating_period.rating_period_end_dt DESC,
                                        member_rating_period.rating_finalized_flag DESC,
                                        mr.total_score_amt DESC) AS rn
        FROM {{ ref('atm_member_rating') }}_hstr mr
        INNER JOIN member_rating_period
            ON member_rating_period.member_rating_period_code = mr.member_rating_period_code
        WHERE mr.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND mr.ds_rcrd_st = 'ACTIVE'
            AND member_rating_period.rating_period_end_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    ) t
    WHERE rn = 1
),

fund_agg AS (
    SELECT
        investment_fund.fmc_id,
        COUNT(*) AS fund_count
    FROM investment_fund
    GROUP BY investment_fund.fmc_id
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
        fmc_id,
        period_tp_code,
        rpt_nm,
        submitted_dt,
        CASE period_tp_code
            WHEN '3' THEN LAST_DAY(MAKE_DATE(rpt_year, CAST(COALESCE(NULLIF(REGEXP_EXTRACT(period_val, '^T(\\d{2})/', 1), ''), period_val) AS INT), 1))
            WHEN '4' THEN LAST_DAY(MAKE_DATE(rpt_year, 3 * CAST(COALESCE(NULLIF(REGEXP_EXTRACT(period_val, '^Q(\\d)/', 1), ''), period_val) AS INT), 1))
            WHEN '5' THEN MAKE_DATE(rpt_year, 6, 30)
            WHEN '6' THEN MAKE_DATE(rpt_year, 12, 31)
        END AS period_end_dt
    FROM {{ ref('atm_fmr_submission') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_RPT_MEMBER'
        AND record_tp = '2'
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
        column_label_nm,
        version_nbr
    FROM {{ ref('dtm_fund_management_rpt_cell_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SHEET'
),

rpt_cell_val AS (
    SELECT
        fmr_submission.fmc_id,
        CASE
            WHEN cell.fmr_sheet_nm = 'CoCauToChuc_06018' AND LOWER(cell.fmr_nm) LIKE '%hoạt động%'
                AND cell.row_indicator_code = '170515' AND cell.column_label_nm = 'Kỳ báo cáo'
                THEN 'certified_practitioner_staff_count'
            WHEN cell.fmr_sheet_nm = 'HDQuanLyQuy_06014' AND LOWER(cell.fmr_nm) LIKE '%hoạt động%'
                AND cell.row_indicator_code = '170103' AND cell.column_label_nm like 'Tổng%'
                THEN 'assets_under_management_amt'
            WHEN cell.fmr_sheet_nm = 'BangTongHop_06013' AND LOWER(cell.fmr_nm) LIKE '%an toàn tài chính%'
                AND cell.row_indicator_code = '4055' AND cell.column_label_nm = 'Giá trị rủi ro/vốn khả dụng'
                THEN 'capital_adequacy_ratio'
            WHEN cell.fmr_sheet_nm = 'BCKetQuaHoatDongKinhDoanh' AND LOWER(cell.fmr_nm) LIKE '%báo cáo tài chính%'
                AND cell.column_label_nm like 'Kỳ này%'
                THEN 'net_profit_after_tax_amt'
            WHEN cell.fmr_sheet_nm = 'BangCanDoiKeToan' AND LOWER(cell.fmr_nm) LIKE '%báo cáo tài chính%'
                AND cell.column_label_nm like 'Số cuối kỳ%'
                THEN 'owner_equity_amt'
            WHEN cell.fmr_sheet_nm = 'Chung_TinhHinhQLDMDT_06020' AND LOWER(cell.fmr_nm) LIKE '%hoạt động%'
                AND cell.row_indicator_code = '180101' AND cell.column_label_nm = 'Kỳ báo cáo'
                THEN 'portfolio_management_contract_count'
        END                                                                             AS kpi_code,
        try_cast(regexp_replace(CAST(fmr_value.cell_val AS string), '%', '') AS decimal(38,8)) AS cell_numeric_val,
        fmr_submission.period_end_dt,
        fmr_submission.period_tp_code,
        cell.version_nbr                                                                AS tpl_version,
        fmr_submission.rpt_nm,
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
        fmc_id,
        MAX(CASE WHEN kpi_code = 'certified_practitioner_staff_count'  THEN cell_numeric_val END) AS certified_practitioner_staff_count,
        MAX(CASE WHEN kpi_code = 'assets_under_management_amt'         THEN cell_numeric_val END) AS assets_under_management_amt,
        MAX(CASE WHEN kpi_code = 'capital_adequacy_ratio'              THEN cell_numeric_val END) AS capital_adequacy_ratio,
        MAX(CASE WHEN kpi_code = 'net_profit_after_tax_amt'            THEN cell_numeric_val END) AS net_profit_after_tax_amt,
        MAX(CASE WHEN kpi_code = 'owner_equity_amt'                    THEN cell_numeric_val END) AS owner_equity_amt,
        MAX(CASE WHEN kpi_code = 'portfolio_management_contract_count' THEN cell_numeric_val END) AS portfolio_management_contract_count
    FROM (
        SELECT
            fmc_id,
            kpi_code,
            cell_numeric_val,
            ROW_NUMBER() OVER (PARTITION BY fmc_id, kpi_code
                               ORDER BY period_end_dt DESC,
                                        period_tp_code DESC,
                                        tpl_version DESC,
                                        CASE WHEN LOWER(rpt_nm) LIKE '%kiểm toán%' OR LOWER(rpt_nm) LIKE '%soát xét%' THEN 1 ELSE 2 END ASC,
                                        submitted_dt DESC,
                                        fmr_val_code DESC) AS rn
        FROM (
            SELECT
                rpt_cell_val.*,
                CASE WHEN kpi_code IN ('net_profit_after_tax_amt', 'owner_equity_amt') THEN 1 ELSE 0 END AS bctc_ind
            FROM rpt_cell_val
            WHERE kpi_code IS NOT NULL
        ) v
        WHERE (bctc_ind = 0 AND period_tp_code = '3')
            OR (bctc_ind = 1 AND period_tp_code IN ('4','5','6')
                AND period_end_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
    ) t
    WHERE rn = 1
    GROUP BY fmc_id
)

SELECT
    CAST(fmc.fmc_code AS string)                                                                AS fmc_code
    , CAST(fmc.fmc_full_nm AS string)                                                           AS fmc_full_nm
    , CAST(fmc.fmc_short_nm AS string)                                                          AS fmc_short_nm
    , CAST(cl_fms_status.cl_fms_status_nm AS string)                                            AS operation_status_nm
    , CAST(CASE WHEN fmc.legal_representative_ind = '1' THEN fmc.director_full_nm END AS string) AS legal_representative_nm
    , CAST(COALESCE(fund_agg.fund_count, 0) AS int)                                             AS fund_count
    , CAST(member_rating.rating_class_code AS string)                                           AS rating_class_code
    , CAST(member_rating.total_score_amt AS int)                                                AS total_score_amt
    , CAST(fmc.charter_capital_amt AS decimal(23,2))                                            AS charter_capital_amt
    , CAST(rpt_kpi.certified_practitioner_staff_count AS int)                                   AS certified_practitioner_staff_count
    , CAST(rpt_kpi.assets_under_management_amt AS decimal(23,2))                                AS assets_under_management_amt
    , CAST(rpt_kpi.capital_adequacy_ratio AS decimal(9,2))                                      AS capital_adequacy_ratio
    , CAST(rpt_kpi.net_profit_after_tax_amt AS decimal(23,2))                                   AS net_profit_after_tax_amt
    , CAST(rpt_kpi.owner_equity_amt AS decimal(23,2))                                           AS owner_equity_amt
    , CAST(rpt_kpi.portfolio_management_contract_count AS int)                                  AS portfolio_management_contract_count
    , CAST(fmc.src_stm_code AS string)                                                          AS src_stm_code
FROM fund_management_company fmc
LEFT JOIN cl_fms_status
    ON cl_fms_status.cl_fms_status_code = fmc.operation_status_code
LEFT JOIN fund_agg
    ON fund_agg.fmc_id = fmc.fmc_id
LEFT JOIN member_rating
    ON member_rating.fmc_id = fmc.fmc_id
LEFT JOIN rpt_kpi
    ON rpt_kpi.fmc_id = fmc.fmc_id
