/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_profile_change
* Program name: Staging SCMS.SC_FIRM_PROFILE_CHANGE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                             AS id
    , CAST(sc_firm_info_id AS int)                AS sc_firm_info_id
    , CAST(entity_type AS string)                 AS entity_type
    , CAST(entity_id AS int)                      AS entity_id
    , CAST(subject_display_name AS string)        AS subject_display_name
    , CAST(execution_time AS timestamp)           AS execution_time
    , CAST(event_type_id AS int)                  AS event_type_id
    , CAST(event_type_name AS string)             AS event_type_name
    , CAST(before_info AS string)                 AS before_info
    , CAST(after_info AS string)                  AS after_info
    , CAST(license_decision_doc_number AS string) AS license_decision_doc_number
    , CAST(effective_date AS date)                AS effective_date
    , CAST(has_approval_doc AS int)               AS has_approval_doc
    , CAST(performed_by AS int)                   AS performed_by
    , CAST(performer_name AS string)              AS performer_name
    , CAST(after_data_json AS string)             AS after_data_json
    , CAST(admin_procedure_profile_id AS string)  AS admin_procedure_profile_id
FROM {{ source('source_scms', 'raw_sc_firm_profile_change') }}