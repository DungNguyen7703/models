/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_securities_company_personnel_profile
* Program name: Dtm Opr Securities Company Personnel Profile
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
        sc_senior_personnel_id,
        sc_senior_personnel_code,
        sc_code,
        full_nm,
        department,
        position_nm,
        work_start_dt,
        dismissal_dt,
        personnel_status_code,
        src_stm_code
    FROM {{ ref('atm_sc_senior_personnel') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_SENIOR_PERSONNEL'
),

ip_el_adr AS (
    SELECT
        ip_id,
        MAX(CASE WHEN electronic_adr_tp_code = 'EMAIL' THEN electronic_adr_val END) AS email,
        MAX(CASE WHEN electronic_adr_tp_code = 'PHONE' THEN electronic_adr_val END) AS phone
    FROM {{ ref('atm_ip_electronic_address') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND electronic_adr_tp_code IN ('EMAIL', 'PHONE')
        AND src_stm_code = 'SCMS_SC_FIRM_SENIOR_PERSONNEL'
    GROUP BY ip_id
)

SELECT
    CAST(sc_se_pe.sc_senior_personnel_code AS string) AS sc_senior_personnel_code,
    CAST(sc_se_pe.sc_code AS string)                  AS sc_code,
    CAST(sc_se_pe.full_nm AS string)                  AS full_nm,
    CAST(sc_se_pe.department AS string)               AS department,
    CAST(sc_se_pe.position_nm AS string)              AS position_nm,
    CAST(ip_el_adr.email AS string)                   AS email,
    CAST(ip_el_adr.phone AS string)                   AS phone,
    CAST(sc_se_pe.work_start_dt AS date)              AS work_start_dt,
    CAST(sc_se_pe.dismissal_dt AS date)               AS dismissal_dt,
    CAST(sc_se_pe.personnel_status_code AS string)    AS personnel_status_code,
    CAST(sc_se_pe.src_stm_code AS string)             AS src_stm_code
FROM sc_se_pe
LEFT JOIN ip_el_adr
    ON  ip_el_adr.ip_id = sc_se_pe.sc_senior_personnel_id
