/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_fund_management_company_snpst
* Program name: Dtm Fct Fund Management Company Snpst
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-28		claude (draft)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_fct_fund_management_company_snpst.csv
*                                       Oracle TRUNC(LAST_DAY(x)) -> Spark last_day(x)
*                                       LLD atomic_table = foreign_fm_ou -> ref atm_foreign_fund_management_organization_unit
*                                       Grain: 1 dòng toàn thị trường / snapshot (mỗi measure 1 CTE 1 dòng, CROSS JOIN)
* 2026-09-29		claude (draft)		Đổi nguồn atm_* sang bảng Dim QLQ tương ứng (dtm_*_dim_hstr) cho các entity đã có Dim
* 2026-10-07		claude (sync)		Đồng bộ LLD theo Atomic FMS UAT 20261006 (commit 117654ae, 53443cc1): trạng thái: LEFT JOIN cl_fms_status lấy cl_fms_status_nm
*                                       (Dim operation_status_code nay = cl_fms_status_code);
*                                       VPĐD: branch_tp_code (= ou_tp_code) = '0';
*                                       bỏ investment_fund_nav_amt (LLD đã bỏ)
* 2026-10-07		claude				Bo hardcode atomic.uat_atm.cl_fms_status -> ref atm_cl_fms_status (model da tao)
* 2026-10-14		claude (sync)		Đồng bộ LLD commit d18cdaa0 (ETL date bound): investment_fund_count chỉ đếm quỹ có
*                                       decision_issue_dt NULL hoặc last_day(decision_issue_dt) <= last_day(etl_date);
*                                       active_fund_management_company_count + 4 count VPĐD/CN: last_day(...) = -> <=
*                                       (đếm lũy kế tới tháng ETL, không chỉ phát sinh trong tháng)
* 2026-10-24		claude (sync)		Đồng bộ LLD commit 7164d9ca: investment_fund_count chỉ đếm quỹ có giấy tờ
*                                       ESTABLISHMENT_OPERATION_LICENSE (ID_DATE) với last_day(issue_dt) <= last_day(etl_date), bỏ decision_issue_dt;
*                                       active_fund_management_company_count thêm điều kiện (suspension_dt IS NULL OR effective_end_dt IS NULL);
*                                       custodian_bank_count: decision_issue_dt NULL tính là 1900-01-01 (kết quả không đổi, viết lại theo LLD)
*--------------------------------------------------------------------*
*/

WITH cl_fms_status AS (
    SELECT
        cl_fms_status_code,
        cl_fms_status_nm
    FROM {{ ref('atm_cl_fms_status') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND ds_rcrd_end_dt = to_date('2400-01-01')
),

establishment_license AS (
    SELECT DISTINCT
        ip_id
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
        AND identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'
        AND last_day(identification_issue_dt) <= last_day(to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
),

investment_fund AS (
    SELECT
        investment_fund_id
    FROM {{ ref('dtm_investment_fund_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
),

fund_management_company AS (
    SELECT
        fund_management_company.fmc_id,
        LOWER(cl_fms_status.cl_fms_status_nm) AS operation_status_nm_lower,
        fund_management_company.actual_operation_commencement_dt operation_commencement_dt,
        fund_management_company.suspension_dt,
        fund_management_company.effective_end_dt
    FROM {{ ref('dtm_fund_management_company_dim') }}_hstr fund_management_company
    LEFT JOIN cl_fms_status
        ON cl_fms_status.cl_fms_status_code = fund_management_company.operation_status_code
    WHERE fund_management_company.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND fund_management_company.ds_rcrd_st = 'ACTIVE'
        AND fund_management_company.src_stm_code = 'FMS_SECURITIES'
),

foreign_fm_ou AS (
    SELECT
        foreign_fm_ou.foreign_fund_management_organization_unit_id AS foreign_fm_ou_id,
        foreign_fm_ou.branch_tp_code,
        LOWER(cl_fms_status.cl_fms_status_nm) AS operation_status_nm_lower,
        foreign_fm_ou.effective_start_dt
    FROM {{ ref('dtm_foreign_fund_management_organization_unit_dim') }}_hstr foreign_fm_ou
    LEFT JOIN cl_fms_status
        ON cl_fms_status.cl_fms_status_code = foreign_fm_ou.operation_status_code
    WHERE foreign_fm_ou.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND foreign_fm_ou.ds_rcrd_st = 'ACTIVE'
        AND foreign_fm_ou.src_stm_code = 'FMS_FOR_BRCH'
),

custodian_bank AS (
    SELECT
        custodian_bank_id,
        decision_issue_dt
    FROM {{ ref('dtm_custodian_bank_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_BANK_MONI'
),

fund_agg AS (
    SELECT
        COUNT(investment_fund.investment_fund_id)                                             AS investment_fund_count
    FROM investment_fund
    INNER JOIN establishment_license
        ON establishment_license.ip_id = investment_fund.investment_fund_id
),

fmc_agg AS (
    SELECT
        COUNT(CASE WHEN fund_management_company.operation_status_nm_lower = 'hoạt động'
                    AND last_day(fund_management_company.operation_commencement_dt)
                        <= last_day(to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
                    AND (fund_management_company.suspension_dt IS NULL
                         OR fund_management_company.effective_end_dt IS NULL)
                   THEN fund_management_company.fmc_id END)                                   AS active_fund_management_company_count
    FROM fund_management_company
),

foreign_fm_ou_agg AS (
    SELECT
        COUNT(foreign_fm_ou_id)                                                               AS foreign_fund_management_organization_unit_count,
        COUNT(CASE WHEN operation_status_nm_lower = 'hoạt động'
                   THEN foreign_fm_ou_id END)                                                 AS active_foreign_fund_management_organization_unit_count,
        COUNT(CASE WHEN operation_status_nm_lower LIKE '%chờ đóng cửa%'
                   THEN foreign_fm_ou_id END)                                                 AS pending_closure_foreign_fund_management_organization_unit_count,
        COUNT(CASE WHEN operation_status_nm_lower NOT LIKE '%chờ%'
                    AND (operation_status_nm_lower LIKE '%đóng cửa%'
                         OR operation_status_nm_lower LIKE '%chấm dứt%'
                         OR operation_status_nm_lower LIKE '%giải thể%')
                   THEN foreign_fm_ou_id END)                                                 AS closed_foreign_fund_management_organization_unit_count
    FROM foreign_fm_ou
    WHERE branch_tp_code = '0'
        AND last_day(effective_start_dt) <= last_day(to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
),

custodian_bank_agg AS (
    SELECT
        COUNT(CASE WHEN last_day(COALESCE(custodian_bank.decision_issue_dt, to_date('1900-01-01')))
                        <= last_day(to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
                   THEN custodian_bank.custodian_bank_id END)                                 AS custodian_bank_count
    FROM custodian_bank
)

SELECT
    date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')                     AS snpst_dt_dim_id,
    CAST(fund_agg.investment_fund_count AS int)                                               AS investment_fund_count,
    CAST(fmc_agg.active_fund_management_company_count AS int)                                 AS active_fund_management_company_count,
    CAST(foreign_fm_ou_agg.foreign_fund_management_organization_unit_count AS int)            AS foreign_fund_management_organization_unit_count,
    CAST(foreign_fm_ou_agg.active_foreign_fund_management_organization_unit_count AS int)     AS active_foreign_fund_management_organization_unit_count,
    CAST(foreign_fm_ou_agg.pending_closure_foreign_fund_management_organization_unit_count AS int) AS pending_closure_foreign_fund_management_organization_unit_count,
    CAST(foreign_fm_ou_agg.closed_foreign_fund_management_organization_unit_count AS int)     AS closed_foreign_fund_management_organization_unit_count,
    CAST(custodian_bank_agg.custodian_bank_count AS int)                                      AS custodian_bank_count
FROM fund_agg
CROSS JOIN fmc_agg
CROSS JOIN foreign_fm_ou_agg
CROSS JOIN custodian_bank_agg
