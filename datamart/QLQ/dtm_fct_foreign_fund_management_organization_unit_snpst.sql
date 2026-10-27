/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_foreign_fund_management_organization_unit_snpst
* Program name: Dtm Fct Foreign Fund Management Organization Unit Snpst
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-28		claude (draft)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_fct_foreign_fund_management_organization_unit_snpst.csv
*                                       LLD atomic_table = foreign_fm_ou -> ref atm_foreign_fund_management_organization_unit
*                                       (model scd4a chính thức cho FMS_FOR_BRCH, cùng cột foreign_fm_ou_*)
*                                       Grain: 1 dòng toàn thị trường / snapshot
* 2026-09-29		claude (draft)		Đổi nguồn atm_* sang bảng Dim QLQ tương ứng (dtm_*_dim_hstr) cho các entity đã có Dim
* 2026-10-07		claude (sync)		Đồng bộ LLD theo Atomic FMS UAT 20261006 (commit 117654ae, 53443cc1): Chi nhánh: branch_tp_code (= Atomic ou_tp_code) = '1'
*                                       thay cho 'BRANCH'
* 2026-10-24		claude (sync)		Đồng bộ LLD commit 7164d9ca: branch_count — ngày bắt đầu = COALESCE(effective_start_dt, ngày cấp
*                                       giấy phép ESTABLISHMENT_OPERATION_LICENSE nhỏ nhất từ atm_ip_alternative_identification, src FMS_FOR_BRCH)
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
        foreign_fm_ou.branch_tp_code,
        COALESCE(foreign_fm_ou.effective_start_dt,
                 establishment_license.identification_issue_dt) AS effective_start_dt,
        foreign_fm_ou.effective_end_dt
    FROM {{ ref('dtm_foreign_fund_management_organization_unit_dim') }}_hstr foreign_fm_ou
    LEFT JOIN establishment_license
        ON establishment_license.ip_id = foreign_fm_ou.foreign_fund_management_organization_unit_id
    WHERE foreign_fm_ou.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND foreign_fm_ou.ds_rcrd_st = 'ACTIVE'
        AND foreign_fm_ou.src_stm_code = 'FMS_FOR_BRCH'
)

SELECT
    date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')                     AS snpst_dt_dim_id,
    CAST(COUNT(CASE WHEN branch_tp_code = '1'
                        AND effective_start_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
                        AND (effective_end_dt IS NULL
                            OR effective_end_dt > to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
                    THEN foreign_fm_ou_id END) AS int)                                     AS branch_count
FROM foreign_fm_ou
