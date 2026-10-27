/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_individual_listed_company_role
* Program name: Dtm Opr Individual Listed Company Role
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 
*--------------------------------------------------------------------*
*/

WITH sc_in_re_pe AS (
    SELECT 
        sc_insider_related_person_code, 
        sc_senior_personnel_code, 
        sc_code, 
        representative_position, 
        shares_count, 
        src_stm_code
    FROM {{ ref('atm_sc_insider_related_person') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INSIDER_RELATION'
)

SELECT
    CAST(sc_insider_related_person_code AS string) AS sc_insider_related_person_code,
    CAST(sc_senior_personnel_code AS string)       AS sc_senior_personnel_code,
    CAST(sc_code AS string)                        AS sc_code,
    CAST(representative_position AS string)        AS representative_position,
    CAST(shares_count AS int)                      AS shares_count,
    CAST(src_stm_code AS string)                   AS src_stm_code
FROM sc_in_re_pe
