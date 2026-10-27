/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_profile_history
* Program name: Staging SCMS.SC_FIRM_PROFILE_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                             AS id
    , CAST(detail_id AS int)                      AS detail_id
    , CAST(linked_table AS string)                AS linked_table
    , CAST(document_type AS string)               AS document_type
    , CAST(document_number AS string)             AS document_number
    , CAST(approval_date AS timestamp)            AS approval_date
    , CAST(valid_date AS timestamp)               AS valid_date
    , CAST(reason AS string)                      AS reason
    , CAST(note AS string)                        AS note
    , CAST(attachment_path AS string)             AS attachment_path
    , CAST(start_date AS timestamp)               AS start_date
    , CAST(end_date AS timestamp)                 AS end_date
    , CAST(expected_suspension_date AS timestamp) AS expected_suspension_date
    , CAST(expected_operation_date AS timestamp)  AS expected_operation_date
    , CAST(inspection_level AS string)            AS inspection_level
    , CAST(approval_authority AS string)          AS approval_authority
    , CAST(created_by AS int)                     AS created_by
    , CAST(created_at AS timestamp)               AS created_at
    , CAST(approved_by AS int)                    AS approved_by
    , CAST(approved_at AS timestamp)              AS approved_at
    , CAST(record_status AS int)                  AS record_status
    , CAST(event_type_id AS int)                  AS event_type_id
    , CAST(sc_firm_info_id AS int)                AS sc_firm_info_id
    , CAST(change_history AS string)              AS change_history
    , CAST(id_old AS int)                         AS id_old
    , CAST(approval_attachment_path AS string)    AS approval_attachment_path
    , CAST(legacy_filename AS string)             AS legacy_filename
    , CAST(legacy_filedata AS string)             AS legacy_filedata
    , CAST(legacy_rowid AS string)                AS legacy_rowid
FROM {{ source('source_scms', 'raw_sc_firm_profile_history') }}