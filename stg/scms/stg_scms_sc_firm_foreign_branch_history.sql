/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_foreign_branch_history
* Program name: Staging SCMS.SC_FIRM_FOREIGN_BRANCH_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                            AS id
    , CAST(sc_firm_foreign_branch_id AS int)     AS sc_firm_foreign_branch_id
    , CAST(event_type_id AS int)                 AS event_type_id
    , CAST(after_data_json AS string)            AS after_data_json
    , CAST(before_data_json AS string)           AS before_data_json
    , CAST(document_file_path AS string)         AS document_file_path
    , CAST(note AS string)                       AS note
    , CAST(effective_date AS date)               AS effective_date
    , CAST(performed_by AS int)                  AS performed_by
    , CAST(performer_name AS string)             AS performer_name
    , CAST(document_number AS string)            AS document_number
    , CAST(event_type_name AS string)            AS event_type_name
    , CAST(performed_at AS timestamp)            AS performed_at
    , CAST(after_info AS string)                 AS after_info
    , CAST(before_info AS string)                AS before_info
    , CAST(admin_procedure_profile_id AS string) AS admin_procedure_profile_id
FROM {{ source('source_scms', 'raw_sc_firm_foreign_branch_history') }}