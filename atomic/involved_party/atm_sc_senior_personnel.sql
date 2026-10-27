/*
*--------------------------------------------------------------------*
* Program code: atm_sc_senior_personnel
* Program name: Atomic Securities Company Senior Personnel
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_se_pe AS (
    SELECT
        id
        , sc_firm_info_id
        , sc_firm_branch_id
        , sc_firm_transaction_office_id
        , sc_firm_rep_office_id
        , full_name
        , entity_type
        , gender
        , date_of_birth
        , place_of_birth
        , nationality_id
        , personnel_status
        , record_status
        , provisional
        , legal_representative
        , statutory_representative
        , disclosure_person_id_alt
        , disclosure_person_id
        , department
        , position_id
        , position
        , position_ids
        , appointment_date
        , work_start_date
        , dismissal_date
        , resignation_date
        , securities_license
        , securities_license_number
        , securities_license_date
        , shareholder_type
        , contributed_capital
        , ownership_ratio_date
        , practitioner_legacy_id
        , business_division_id
        , responsible_service_id
        , report_content
        , deleted
        , attachment_path
        , note
    FROM {{ ref('ods_scms_sc_firm_senior_personnel') }}
),

sc_fi_in AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_scms_sc_firm_info') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_SENIOR_PERSONNEL', "sc_fi_se_pe.id") }}                                AS sc_senior_personnel_id
    , CAST(sc_fi_se_pe.id AS string)                                                                                      AS sc_senior_personnel_code
    , CAST('SCMS_SC_FIRM_SENIOR_PERSONNEL' AS string)                                                                     AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}                                           AS sc_id
    , CAST(sc_fi_se_pe.sc_firm_info_id AS string)                                                                         AS sc_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_BRANCH', "sc_fi_se_pe.sc_firm_branch_id") }}                         AS branch_ou_id
    , CAST(sc_fi_se_pe.sc_firm_branch_id AS string)                                                                       AS branch_ou_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_TRANSACTION_OFFICE', "sc_fi_se_pe.sc_firm_transaction_office_id") }} AS transaction_office_ou_id
    , CAST(sc_fi_se_pe.sc_firm_transaction_office_id AS string)                                                           AS transaction_office_ou_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_REP_OFFICE', "sc_fi_se_pe.sc_firm_rep_office_id") }}                 AS representative_office_ou_id
    , CAST(sc_fi_se_pe.sc_firm_rep_office_id AS string)                                                                   AS representative_office_ou_code
    , CAST(sc_fi_se_pe.full_name AS string)                                                                               AS full_nm
    , CAST(sc_fi_se_pe.entity_type AS string)                                                                             AS entity_tp_code
    , CAST(sc_fi_se_pe.gender AS string)                                                                                  AS gender_code
    , CAST(sc_fi_se_pe.date_of_birth AS date)                                                                             AS dt_of_birth
    , CAST(sc_fi_se_pe.place_of_birth AS string)                                                                          AS place_of_birth
    , {{ generate_surrogate_key_bigint('SCMS_CAT_NATIONALITY', "sc_fi_se_pe.nationality_id") }}                           AS cl_nationality_id
    , CAST(sc_fi_se_pe.nationality_id AS string)                                                                          AS cl_nationality_code
    , CAST(sc_fi_se_pe.personnel_status AS string)                                                                        AS personnel_status_code
    , CAST(sc_fi_se_pe.record_status AS string)                                                                           AS record_status_code
    , CAST(sc_fi_se_pe.provisional AS string)                                                                             AS provisional_status_code
    , CAST(sc_fi_se_pe.legal_representative AS int)                                                                       AS legal_representative_indicator
    , CAST(sc_fi_se_pe.statutory_representative AS int)                                                                   AS statutory_representative_indicator
    , CAST(sc_fi_se_pe.disclosure_person_id_alt AS int)                                                                           AS disclosure_person_indicator
    , {{ generate_surrogate_key_bigint('IAM_USERS', "sc_fi_se_pe.disclosure_person_id") }}                                AS disclosure_person_id
    , CAST(sc_fi_se_pe.disclosure_person_id AS string)                                                                    AS disclosure_person_code
    , CAST(sc_fi_se_pe.department AS string)                                                                              AS department
    , CAST(sc_fi_se_pe.position_id AS string)                                                                             AS position_code
    , CAST(sc_fi_se_pe.position AS string)                                                                                AS position_nm
    , CAST(sc_fi_se_pe.position_ids AS string)                                                                            AS position_ids
    , CAST(sc_fi_se_pe.appointment_date AS date)                                                                          AS appointment_dt
    , CAST(sc_fi_se_pe.work_start_date AS date)                                                                           AS work_start_dt
    , CAST(sc_fi_se_pe.dismissal_date AS date)                                                                            AS dismissal_dt
    , CAST(sc_fi_se_pe.resignation_date AS date)                                                                          AS resignation_dt
    , CAST(sc_fi_se_pe.securities_license AS int)                                                                         AS securities_license_indicator
    , CAST(sc_fi_se_pe.securities_license_number AS string)                                                               AS securities_license_nbr
    , CAST(sc_fi_se_pe.securities_license_date AS date)                                                                   AS securities_license_dt
    , CAST(sc_fi_se_pe.shareholder_type AS string)                                                                        AS shareholder_tp_code
    , CAST(sc_fi_se_pe.contributed_capital AS decimal(23,2))                                                              AS contributed_capital_amt
    , CAST(sc_fi_se_pe.ownership_ratio_date AS date)                                                                      AS ownership_ratio_dt
    , CAST(sc_fi_se_pe.practitioner_legacy_id AS string)                                                                  AS legacy_practitioner_id
    , CAST(sc_fi_se_pe.business_division_id AS string)                                                                    AS business_division_id
    , CAST(sc_fi_se_pe.responsible_service_id AS string)                                                                  AS responsible_service_id
    , CAST(sc_fi_se_pe.report_content AS string)                                                                          AS rpt_content
    , CAST(sc_fi_se_pe.deleted AS int)                                                                                    AS deleted_indicator
    , CAST(sc_fi_se_pe.attachment_path AS string)                                                                         AS attachment_path
    , CAST(sc_fi_se_pe.note AS string)                                                                                    AS note
FROM sc_fi_se_pe
    LEFT JOIN sc_fi_in ON sc_fi_se_pe.SC_FIRM_INFO_ID = sc_fi_in.ID