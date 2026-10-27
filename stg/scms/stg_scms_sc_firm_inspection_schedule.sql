/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_inspection_schedule
* Program name: Staging SCMS.SC_FIRM_INSPECTION_SCHEDULE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                          AS id
    , CAST(sc_firm_info_id AS int)             AS sc_firm_info_id
    , CAST(record_type AS string)              AS record_type
    , CAST(amount AS int)                      AS amount
    , CAST(start_date AS date)                 AS start_date
    , CAST(end_date AS date)                   AS end_date
    , CAST(decision_content AS string)         AS decision_content
    , CAST(decision_date AS date)              AS decision_date
    , CAST(inspector_name AS string)           AS inspector_name
    , CAST(created_by AS int)                  AS created_by
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(last_modified_by AS int)            AS last_modified_by
    , CAST(last_modified_at AS timestamp)      AS last_modified_at
    , CAST(record_status AS int)               AS record_status
    , CAST(attachment_path AS string)          AS attachment_path
    , CAST(implementing_unit AS string)        AS implementing_unit
    , CAST(decision_file_path AS string)       AS decision_file_path
    , CAST(conclusion_doc_file_path AS string) AS conclusion_doc_file_path
    , CAST(form_type AS string)                AS form_type
    , CAST(conclusion_summary AS string)       AS conclusion_summary
    , CAST(recommendations AS string)          AS recommendations
    , CAST(inspection_type AS string)          AS inspection_type
    , CAST(conclusion_doc_date AS date)        AS conclusion_doc_date
    , CAST(decision_number AS string)          AS decision_number
    , CAST(conclusion_doc_number AS string)    AS conclusion_doc_number
    , CAST(inspection_team_json AS string)     AS inspection_team_json
    , CAST(to_date AS date)                    AS to_date
    , CAST(from_date AS date)                  AS from_date
    , CAST(period_to_date AS date)             AS period_to_date
    , CAST(period_from_date AS date)           AS period_from_date
    , CAST(team_leader AS string)              AS team_leader
    , CAST(content AS string)                  AS content
    , CAST(deleted AS int)                     AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_inspection_schedule') }}