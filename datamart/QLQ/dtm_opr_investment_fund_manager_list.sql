/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_investment_fund_manager_list
* Program name: Dtm Opr Investment Fund Manager List
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-28		claude (draft)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_opr_investment_fund_manager_list_FMS_FUND_TL_PRO.csv
*                                       LLD atomic_table = fmc_employee_x_investment_fund_relationship
*                                       -> ref atm_investment_fund_x_fmc_employee_relationship (scd2, src FMS_FUND_TL_PRO)
*                                       CHƯA CÓ model atm_fmc_employee -> enabled: false
* 2026-10-07		claude				Đổi ref sang atm_fmc_employee_x_investment_fund_relationship (Atomic đổi tên theo LLD)
*--------------------------------------------------------------------*
*/

WITH fmc_employee_x_investment_fund_relationship AS (
    SELECT
        investment_fund_code,
        fmc_employee_id,
        fmc_employee_code,
        src_stm_code
    FROM {{ ref('atm_fmc_employee_x_investment_fund_relationship') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUND_TL_PRO'
),

fmc_employee AS (
    SELECT
        fmc_employee_id,
        fmc_employee_full_nm
    FROM {{ ref('atm_fmc_employee') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_TL_PROFILES'
)

SELECT
    CAST(rltnp.investment_fund_code AS string)                                                  AS investment_fund_code
    , CAST(rltnp.fmc_employee_code AS string)                                                   AS fmc_employee_code
    , CAST(fmc_employee.fmc_employee_full_nm AS string)                                         AS fmc_employee_full_nm
    , CAST(rltnp.src_stm_code AS string)                                                        AS src_stm_code
FROM fmc_employee_x_investment_fund_relationship rltnp
LEFT JOIN fmc_employee
    ON fmc_employee.fmc_employee_id = rltnp.fmc_employee_id
