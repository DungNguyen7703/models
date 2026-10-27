/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_fund_distribution_agent_profile
* Program name: Dtm Opr Fund Distribution Agent Profile
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-28		claude (draft)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_opr_fund_distribution_agent_profile_FMS_DISTRIBUTOR_AGENT.csv
*                                       CHƯA CÓ model atm_securities_distribution_agent; ip_alternative_identification /
*                                       ip_postal_address chưa có nhánh FMS_DISTRIBUTOR_AGENT -> enabled: false
*                                       license/address: dedupe ROW_NUMBER (1 dòng/ĐLPP) tránh nhân bản PK
* 2026-09-29		claude (draft)		Đổi nguồn atm_* sang bảng Dim QLQ tương ứng (dtm_*_dim_hstr) cho các entity đã có Dim
* 2026-10-07		claude (sync)		Đồng bộ LLD theo Atomic FMS UAT 20261006 (commit 117654ae, 53443cc1): active_status_flag = CASE WHEN termination_dt IS NULL THEN 1 ELSE 0 END
* 2026-10-14		claude (sync)		Đồng bộ LLD commit 2f62880d: thêm distributing_fund_count + 15 KPI báo cáo TinhHinhGiaoDichCCQ_06268 (record_tp '8').
*                                       distributing_fund_count: dtm_fund_distribution_agent_dim_hstr (src FMS_AGENCIES) x atm_fund_distribution_agent_
*                                       x_investment_fund_relationship (scd2, src FMS_AGEN_FUNDS), khớp ĐLPP theo short_nm hoặc LOWER(TRIM(full_nm)).
*                                       KPI 1 ô: FETCH FIRST 1 ROW -> ROW_NUMBER (rpt_year, period_val của fmr_value, submitted_dt, tie-breaker fmr_val_code).
*                                       KPI SUM (issued_amt, issued_year_to_dt_amt, redeemed_amt): SUM theo bản nộp (fmr_submission_id, rpt_year,
*                                       period_val, submitted_dt của fmr_submission) rồi lấy bản nộp mới nhất (tie-breaker fmr_submission_id).
*                                       TO_NUMBER -> try_cast (schema-changing)
* 2026-10-14		claude (sync)		Đồng bộ LLD commit d18cdaa0 (ETL date bound): KPI báo cáo định kỳ chỉ xét bản nộp có
*                                       fmr_submission.submitted_dt <= etl_date (lọc trong CTE fmr_submission)
* 2026-10-24		claude (sync)		Đồng bộ LLD commit 576f001c: KPI báo cáo định kỳ lọc record_tp = '8' theo fmr_submission (RPT_MEMBER) thay cho
*                                       fmr_value, thêm record_status_code IN ('2','3','5','10') (logic-only, schema không đổi).
*                                       Ngoài literal LLD: GIỮ nối bản nộp -> đại lý theo securities_distribution_agent_code (LLD ghi _id) vì
*                                       dtm_securities_distribution_agent_dim vẫn sinh PK bằng generate_surrogate_key_bigint (LLD dim chưa áp A23)
*                                       -> nối theo id sẽ rỗng toàn bộ 15 KPI; đổi sang _id khi dim chuyển PK = id Atomic
* 2026-10-24		claude (sync)		Đồng bộ LLD commit 7164d9ca: bộ lọc dòng — chỉ ĐLPP có giấy phép ESTABLISHMENT_OPERATION_LICENSE
*                                       (src FMS_DISTRIBUTOR_AGENT) cấp <= etl_date (EXISTS LLD -> CTE operation_license DISTINCT + INNER JOIN,
*                                       cùng điều kiện dtm_fct_fund_distribution_agent_snpst); 14 KPI báo cáo chọn kỳ mới nhất theo
*                                       rpt_year/period_val/period_tp_code của fmr_submission (KPI 1 ô trước đây lấy theo fmr_value)
*                                       (logic-only, schema không đổi)
*--------------------------------------------------------------------*
*/

WITH securities_distribution_agent AS (
    SELECT
        securities_distribution_agent_id,
        securities_distribution_agent_code,
        securities_distribution_agent_full_nm,
        securities_distribution_agent_short_nm,
        termination_dt,
        src_stm_code
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
),

business_license AS (
    SELECT
        ip_id,
        identification_nbr,
        identification_issue_dt
    FROM (
        SELECT
            ip_id,
            identification_nbr,
            identification_issue_dt,
            ROW_NUMBER() OVER (PARTITION BY ip_id ORDER BY identification_issue_dt DESC, identification_nbr) AS rn
        FROM {{ ref('atm_ip_alternative_identification') }}_hstr
        WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND ds_rcrd_st = 'ACTIVE'
            AND src_stm_code = 'FMS_DISTRIBUTOR_AGENT'
            AND identification_tp_code = 'BUSINESS_LICENSE'
    ) t
    WHERE rn = 1
),

head_office AS (
    SELECT
        ip_id,
        adr_val
    FROM (
        SELECT
            ip_id,
            adr_val,
            ROW_NUMBER() OVER (PARTITION BY ip_id ORDER BY adr_val) AS rn
        FROM {{ ref('atm_ip_postal_address') }}_hstr
        WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND ds_rcrd_st = 'ACTIVE'
            AND src_stm_code = 'FMS_DISTRIBUTOR_AGENT'
            AND adr_tp_code = 'HEAD_OFFICE'
    ) t
    WHERE rn = 1
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

fund_distribution_agent_x_investment_fund_relationship AS (
    SELECT
        CAST(fund_distribution_agent_id AS string)                              AS fund_distribution_agent_id,
        investment_fund_code
    FROM {{ ref('atm_fund_distribution_agent_x_investment_fund_relationship') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_AGEN_FUNDS'
),

distributing_fund_agg AS (
    SELECT
        sda.securities_distribution_agent_code,
        COUNT(DISTINCT rltnp.investment_fund_code)                              AS distributing_fund_count
    FROM securities_distribution_agent sda
    INNER JOIN fund_distribution_agent fda
        ON fda.fund_distribution_agent_short_nm = sda.securities_distribution_agent_short_nm
        OR LOWER(TRIM(fda.fund_distribution_agent_full_nm)) = LOWER(TRIM(sda.securities_distribution_agent_full_nm))
    INNER JOIN fund_distribution_agent_x_investment_fund_relationship rltnp
        ON rltnp.fund_distribution_agent_id = fda.fund_distribution_agent_id
    GROUP BY sda.securities_distribution_agent_code
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
        securities_distribution_agent_code,
        rpt_year,
        period_val,
        period_tp_code,
        submitted_dt
    FROM {{ ref('atm_fmr_submission') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_RPT_MEMBER'
        AND record_tp = '8'
        AND record_status_code IN ('2','3','5','10')
        AND submitted_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
),

fund_management_rpt_cell AS (
    SELECT
        fmr_sheet_code,
        cell_id,
        fmr_nm,
        fmr_sheet_nm,
        row_stt_code,
        column_label_nm
    FROM {{ ref('dtm_fund_management_rpt_cell_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_SHEET'
),

rpt_cell_val AS (
    -- Mọi KPI cùng sheet TinhHinhGiaoDichCCQ_06268 / mẫu ĐLPP; phân biệt theo row_stt_code + column_label_nm
    SELECT
        fmr_submission.securities_distribution_agent_code,
        CASE
            WHEN cell.row_stt_code = '1' AND cell.column_label_nm = 'Kỳ báo cáo' THEN 'trading_account_count'
            WHEN cell.row_stt_code = '1' AND cell.column_label_nm = 'Lũy kế từ đầu năm đến kỳ báo cáo' THEN 'trading_account_year_to_dt_count'
            WHEN cell.row_stt_code = '2.1' AND cell.column_label_nm = 'Kỳ báo cáo' THEN 'institution_trading_account_count'
            WHEN cell.row_stt_code = '2.2' AND cell.column_label_nm = 'Kỳ báo cáo' THEN 'individual_trading_account_count'
            WHEN cell.row_stt_code = '2.3' AND cell.column_label_nm = 'Kỳ báo cáo' THEN 'foreign_trading_account_count'
            WHEN cell.row_stt_code = '3.1' AND cell.column_label_nm = 'Kỳ báo cáo' THEN 'institution_holding_account_count'
            WHEN cell.row_stt_code = '3.2' AND cell.column_label_nm = 'Kỳ báo cáo' THEN 'individual_holding_account_count'
            WHEN cell.row_stt_code = '3.3' AND cell.column_label_nm = 'Kỳ báo cáo' THEN 'foreign_holding_account_count'
            WHEN cell.row_stt_code = '4.1' AND cell.column_label_nm = 'Kỳ báo cáo' THEN 'institution_fund_certificate_amt'
            WHEN cell.row_stt_code = '4.2' AND cell.column_label_nm = 'Kỳ báo cáo' THEN 'individual_fund_certificate_amt'
            WHEN cell.row_stt_code = '4.3' AND cell.column_label_nm = 'Kỳ báo cáo' THEN 'foreign_fund_certificate_amt'
        END                                                                             AS kpi_code,
        CASE
            WHEN cell.row_stt_code IN ('5.1', '5.2', '5.3') AND cell.column_label_nm = 'Kỳ báo cáo' THEN 'issued_amt'
            WHEN cell.row_stt_code IN ('5.1', '5.2', '5.3') AND cell.column_label_nm = 'Lũy kế từ đầu năm đến kỳ báo cáo' THEN 'issued_year_to_dt_amt'
            WHEN cell.row_stt_code IN ('6.1', '6.2', '6.3') AND cell.column_label_nm = 'Kỳ báo cáo' THEN 'redeemed_amt'
        END                                                                             AS sum_kpi_code,
        try_cast(regexp_replace(CAST(fmr_value.cell_val AS string), '%', '') AS decimal(38,8)) AS cell_numeric_val,
        fmr_value.fmr_submission_id,
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
    WHERE cell.fmr_sheet_nm = 'TinhHinhGiaoDichCCQ_06268'
        AND LOWER(cell.fmr_nm) LIKE '%đại lý phân phối%'
),

rpt_kpi_candidate AS (
    -- KPI 1 ô
    SELECT
        securities_distribution_agent_code,
        kpi_code,
        cell_numeric_val,
        rpt_year,
        period_month_no,
        period_tp_code,
        submitted_dt,
        fmr_val_code                                                                    AS tie_breaker
    FROM rpt_cell_val
    WHERE kpi_code IS NOT NULL
    UNION ALL
    -- KPI SUM theo bản nộp
    SELECT
        securities_distribution_agent_code,
        sum_kpi_code                                                                    AS kpi_code,
        SUM(cell_numeric_val)                                                           AS cell_numeric_val,
        rpt_year,
        period_month_no,
        period_tp_code,
        submitted_dt,
        CAST(fmr_submission_id AS string)                                               AS tie_breaker
    FROM rpt_cell_val
    WHERE sum_kpi_code IS NOT NULL
    GROUP BY securities_distribution_agent_code, sum_kpi_code, fmr_submission_id, rpt_year, period_month_no, period_tp_code, submitted_dt
),

rpt_kpi AS (
    SELECT
        securities_distribution_agent_code,
        MAX(CASE WHEN kpi_code = 'trading_account_count' THEN cell_numeric_val END) AS trading_account_count,
        MAX(CASE WHEN kpi_code = 'trading_account_year_to_dt_count' THEN cell_numeric_val END) AS trading_account_year_to_dt_count,
        MAX(CASE WHEN kpi_code = 'institution_trading_account_count' THEN cell_numeric_val END) AS institution_trading_account_count,
        MAX(CASE WHEN kpi_code = 'individual_trading_account_count' THEN cell_numeric_val END) AS individual_trading_account_count,
        MAX(CASE WHEN kpi_code = 'foreign_trading_account_count' THEN cell_numeric_val END) AS foreign_trading_account_count,
        MAX(CASE WHEN kpi_code = 'institution_holding_account_count' THEN cell_numeric_val END) AS institution_holding_account_count,
        MAX(CASE WHEN kpi_code = 'individual_holding_account_count' THEN cell_numeric_val END) AS individual_holding_account_count,
        MAX(CASE WHEN kpi_code = 'foreign_holding_account_count' THEN cell_numeric_val END) AS foreign_holding_account_count,
        MAX(CASE WHEN kpi_code = 'institution_fund_certificate_amt' THEN cell_numeric_val END) AS institution_fund_certificate_amt,
        MAX(CASE WHEN kpi_code = 'individual_fund_certificate_amt' THEN cell_numeric_val END) AS individual_fund_certificate_amt,
        MAX(CASE WHEN kpi_code = 'foreign_fund_certificate_amt' THEN cell_numeric_val END) AS foreign_fund_certificate_amt,
        MAX(CASE WHEN kpi_code = 'issued_amt' THEN cell_numeric_val END) AS issued_amt,
        MAX(CASE WHEN kpi_code = 'issued_year_to_dt_amt' THEN cell_numeric_val END) AS issued_year_to_dt_amt,
        MAX(CASE WHEN kpi_code = 'redeemed_amt' THEN cell_numeric_val END) AS redeemed_amt
    FROM (
        SELECT
            securities_distribution_agent_code,
            kpi_code,
            cell_numeric_val,
            ROW_NUMBER() OVER (PARTITION BY securities_distribution_agent_code, kpi_code
                               ORDER BY rpt_year DESC, period_month_no DESC, period_tp_code DESC,
                                        submitted_dt DESC, tie_breaker DESC) AS rn
        FROM rpt_kpi_candidate
    ) t
    WHERE rn = 1
    GROUP BY securities_distribution_agent_code
)

SELECT
    CAST(sda.securities_distribution_agent_code AS string)                                      AS securities_distribution_agent_code
    , CAST(sda.securities_distribution_agent_full_nm AS string)                                 AS securities_distribution_agent_full_nm
    , CAST(business_license.identification_nbr AS string)                                       AS license_nbr
    , CAST(business_license.identification_issue_dt AS date)                                    AS license_dt
    , CAST(head_office.adr_val AS string)                                                       AS address
    , CAST(CASE WHEN sda.termination_dt IS NULL THEN 1 ELSE 0 END AS int)                       AS active_status_flag
    , CAST(sda.termination_dt AS date)                                                          AS termination_dt
    , CAST(COALESCE(distributing_fund_agg.distributing_fund_count, 0) AS int)                   AS distributing_fund_count
    , CAST(rpt_kpi.trading_account_count AS int)                                                AS trading_account_count
    , CAST(rpt_kpi.trading_account_year_to_dt_count AS int)                                     AS trading_account_year_to_dt_count
    , CAST(rpt_kpi.institution_trading_account_count AS int)                                    AS institution_trading_account_count
    , CAST(rpt_kpi.individual_trading_account_count AS int)                                     AS individual_trading_account_count
    , CAST(rpt_kpi.foreign_trading_account_count AS int)                                        AS foreign_trading_account_count
    , CAST(rpt_kpi.institution_holding_account_count AS int)                                    AS institution_holding_account_count
    , CAST(rpt_kpi.individual_holding_account_count AS int)                                     AS individual_holding_account_count
    , CAST(rpt_kpi.foreign_holding_account_count AS int)                                        AS foreign_holding_account_count
    , CAST(rpt_kpi.institution_fund_certificate_amt AS decimal(23,2))                           AS institution_fund_certificate_amt
    , CAST(rpt_kpi.individual_fund_certificate_amt AS decimal(23,2))                            AS individual_fund_certificate_amt
    , CAST(rpt_kpi.foreign_fund_certificate_amt AS decimal(23,2))                               AS foreign_fund_certificate_amt
    , CAST(rpt_kpi.issued_amt AS decimal(23,2))                                                 AS issued_amt
    , CAST(rpt_kpi.issued_year_to_dt_amt AS decimal(23,2))                                      AS issued_year_to_dt_amt
    , CAST(rpt_kpi.redeemed_amt AS decimal(23,2))                                               AS redeemed_amt
    , CAST(sda.src_stm_code AS string)                                                          AS src_stm_code
FROM securities_distribution_agent sda
INNER JOIN operation_license
    ON operation_license.ip_id = sda.securities_distribution_agent_id
LEFT JOIN business_license
    ON business_license.ip_id = sda.securities_distribution_agent_id
LEFT JOIN head_office
    ON head_office.ip_id = sda.securities_distribution_agent_id
LEFT JOIN distributing_fund_agg
    ON distributing_fund_agg.securities_distribution_agent_code = sda.securities_distribution_agent_code
LEFT JOIN rpt_kpi
    ON rpt_kpi.securities_distribution_agent_code = sda.securities_distribution_agent_code
