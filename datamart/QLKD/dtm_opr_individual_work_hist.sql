/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_individual_work_hist
* Program name: Dtm Opr Individual Work Hist
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH sc_se_pe AS (
    SELECT 
        sc_senior_personnel_code, 
        sc_code, 
        position_nm, 
        work_start_dt, 
        resignation_dt, 
        src_stm_code,
        CASE 
            WHEN resignation_dt IS NULL THEN 'CURRENT' 
            ELSE 'PAST' 
        END AS employment_status_code
    FROM {{ ref('atm_sc_senior_personnel') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_SENIOR_PERSONNEL'
)

SELECT
    CAST(sc_senior_personnel_code AS string) AS sc_senior_personnel_code,
    CAST(sc_code AS string)                  AS sc_code,
    CAST(position_nm AS string)              AS position_nm,
    CAST(work_start_dt AS date)              AS work_start_dt,
    CAST(resignation_dt AS date)             AS resignation_dt,
    CAST(employment_status_code AS string)   AS employment_status_code,
    CAST(src_stm_code AS string)             AS src_stm_code
FROM sc_se_pe
