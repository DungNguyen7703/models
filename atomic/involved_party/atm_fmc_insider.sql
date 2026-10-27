/*
*--------------------------------------------------------------------*
* Program code: atm_fmc_insider
* Program name: Atomic Fund Management Company Insider
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH insi AS (
    SELECT
        id
        , sc_id
        , s_id
        , nat_id
        , tlpro_id
        , item_name
        , insider_no
        , tl_profile_linked
        , tl_profile_in_sec
        , insider_type
        , capital
        , qtty
        , reprecent
        , per_date
        , record_status
        , description
        , birth
        , s_work_dte
        , employ_status
        , gp_qd_no
        , approval_date
    FROM {{ ref('ods_fms_insider') }}
),

nati AS (
    SELECT
        id
        , sname
    FROM {{ ref('ods_fms_national') }}
)

SELECT
    {{ generate_surrogate_key_bigint('FMS_INSIDER', "insi.id") }}             AS fmc_insider_id
    , CAST(insi.id AS string)                                                 AS fmc_insider_code
    , CAST('FMS_INSIDER' AS string)                                           AS src_stm_code
    , {{ generate_surrogate_key_bigint('FMS_SECURITIES', "insi.sc_id") }}     AS fmc_id
    , CAST(insi.sc_id AS string)                                              AS fmc_code
    , {{ generate_surrogate_key_bigint('FMS_SECURITIES', "insi.s_id") }}      AS employer_fmc_id
    , CAST(insi.s_id AS string)                                               AS employer_fmc_code
    , {{ generate_surrogate_key_bigint('ECAT_COUNTRY', "nati.sname") }}       AS nationality_id
    , CAST(nati.sname AS string)                                              AS nationality_code
    , {{ generate_surrogate_key_bigint('FMS_TL_PROFILES', "insi.tlpro_id") }} AS fmc_employee_id
    , CAST(insi.tlpro_id AS string)                                           AS fmc_employee_code
    , CAST(insi.item_name AS string)                                          AS fmc_insider_full_nm
    , CAST(insi.insider_no AS string)                                         AS insider_registration_nbr
    , CAST(insi.tl_profile_linked AS int)                                     AS key_person_linked_flag
    , CAST(insi.tl_profile_in_sec AS int)                                     AS practitioner_affiliated_fmc_flag
    , CAST(insi.insider_type AS string)                                       AS insider_tp_code
    , CAST(insi.capital AS decimal(23,2))                                     AS contributed_capital_amt
    , CAST(insi.qtty AS int)                                                  AS held_unit_quantity
    , CAST(insi.reprecent AS decimal(5,2))                                    AS representation_percentage
    , CAST(insi.per_date AS date)                                             AS percentage_determination_dt
    , CAST(insi.record_status AS int)                                         AS active_status_flag
    , CAST(insi.description AS string)                                        AS description
    , CAST(insi.birth AS date)                                                AS birth_dt
    , CAST(insi.s_work_dte AS date)                                           AS employment_start_dt
    , CAST(insi.employ_status AS string)                                      AS employment_status_code
    , CAST(insi.gp_qd_no AS string)                                           AS decision_document_nbr
    , CAST(insi.approval_date AS date)                                        AS approval_dt
FROM insi
    LEFT JOIN nati ON insi.NAT_ID = nati.ID