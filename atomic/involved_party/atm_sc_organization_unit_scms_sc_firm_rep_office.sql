/*
*--------------------------------------------------------------------*
* Program code: atm_sc_organization_unit
* Program name: Atomic Securities Company Organization Unit SCMS.SC_FIRM_REP_OFFICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_re_of AS (
    SELECT
        id
        , sc_firm_info_id
        , sc_firm_branch_id
        , full_name
        , office_name
        , rep_office_status
        , record_status
        , provisional
        , event_type_id
        , decision_number
        , decision_date
        , document_number
        , document_date
        , document_file_path
        , document_declaration
        , valid_dossier_date
        , official_operation_date
        , validity_start_date
        , validity_end_date
        , representative_name
        , representative_id
        , scope_of_operation
        , attachment_path
        , note
    FROM {{ ref('ods_scms_sc_firm_rep_office') }}
),

sc_fi_in AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_scms_sc_firm_info') }}
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_REP_OFFICE', "sc_fi_re_of.id") }}                  AS sc_ou_id
    , CAST(sc_fi_re_of.id AS string)                                                                  AS sc_ou_code
    , CAST('SCMS_SC_FIRM_REP_OFFICE' AS string)                                                       AS src_stm_code
    , CAST('REP_OFFICE' AS string)                                                                    AS ou_tp_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INFO', "sc_fi_in.code") }}                       AS sc_id
    , CAST(sc_fi_re_of.sc_firm_info_id AS string)                                                     AS sc_code
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_BRANCH', "sc_fi_re_of.sc_firm_branch_id") }}     AS parent_ou_id
    , CAST(sc_fi_re_of.sc_firm_branch_id AS string)                                                   AS parent_ou_code
    , CAST(NULL AS string)                                                                            AS ou_code
    , CAST(sc_fi_re_of.full_name AS string)                                                           AS ou_nm
    , CAST(sc_fi_re_of.office_name AS string)                                                         AS ou_legacy_nm
    , CAST(NULL AS string)                                                                            AS ou_english_nm
    , {{ generate_surrogate_key_bigint('SCMS_CAT_SC_FIRM_STATUS', "sc_fi_re_of.rep_office_status") }} AS cl_firm_status_id
    , CAST(sc_fi_re_of.rep_office_status AS string)                                                   AS cl_firm_status_code
    , CAST(sc_fi_re_of.record_status AS string)                                                       AS record_status_code
    , CAST(NULL AS int)                                                                               AS provisional_indicator
    , CAST(sc_fi_re_of.decision_number AS string)                                                     AS decision_nbr
    , CAST(sc_fi_re_of.decision_date AS date)                                                         AS decision_dt
    , CAST(sc_fi_re_of.valid_dossier_date AS date)                                                    AS valid_dossier_dt
    , CAST(NULL AS date)                                                                              AS operation_dt
    , CAST(sc_fi_re_of.official_operation_date AS date)                                               AS official_operation_dt
    , CAST(NULL AS string)                                                                            AS director_nm
    , CAST(sc_fi_re_of.representative_name AS string)                                                 AS representative_nm
    , CAST(NULL AS string)                                                                            AS representative_title
    , CAST(NULL AS string)                                                                            AS personnel_director_id
    , CAST(NULL AS string)                                                                            AS administrative_authority_nm
    , CAST(NULL AS string)                                                                            AS business_lines
    , CAST(sc_fi_re_of.attachment_path AS string)                                                     AS attachment_path
    , CAST(sc_fi_re_of.note AS string)                                                                AS note
    , CAST(sc_fi_re_of.provisional AS string)                                                         AS provisional_status_code
    , {{ generate_surrogate_key_bigint('SCMS_CAT_EVENT_TYPE', "sc_fi_re_of.event_type_id") }}         AS cl_event_tp_id
    , CAST(sc_fi_re_of.event_type_id AS string)                                                       AS cl_event_tp_code
    , CAST(sc_fi_re_of.document_number AS string)                                                     AS document_nbr
    , CAST(sc_fi_re_of.document_date AS date)                                                         AS document_dt
    , CAST(sc_fi_re_of.document_file_path AS string)                                                  AS document_file_path
    , CAST(sc_fi_re_of.document_declaration AS int)                                                   AS document_declaration_indicator
    , CAST(sc_fi_re_of.validity_start_date AS date)                                                   AS validity_start_dt
    , CAST(sc_fi_re_of.validity_end_date AS date)                                                     AS validity_end_dt
    , CAST(sc_fi_re_of.representative_id AS string)                                                   AS representative_id
    , CAST(sc_fi_re_of.scope_of_operation AS string)                                                  AS scope_of_operation
    , CAST(NULL AS string)                                                                            AS decision_nbr_secondary
    , CAST(NULL AS date)                                                                              AS decision_dt_secondary
FROM sc_fi_re_of
    LEFT JOIN sc_fi_in ON sc_fi_re_of.SC_FIRM_INFO_ID = sc_fi_in.ID