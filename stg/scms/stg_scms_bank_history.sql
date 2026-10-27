/*
*--------------------------------------------------------------------*
* Program code: stg_scms_bank_history
* Program name: Staging SCMS.BANK_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                     AS id
    , CAST(bank_id AS int)                AS bank_id
    , CAST(performed_at AS timestamp)     AS performed_at
    , CAST(matter_code AS string)         AS matter_code
    , CAST(event_type_name AS string)     AS event_type_name
    , CAST(content_before AS string)      AS content_before
    , CAST(content_after AS string)       AS content_after
    , CAST(document_number AS string)     AS document_number
    , CAST(effective_date AS date)        AS effective_date
    , CAST(document_file_name AS string)  AS document_file_name
    , CAST(document_file_path AS string)  AS document_file_path
    , CAST(performed_by AS int)           AS performed_by
    , CAST(performer_name AS string)      AS performer_name
    , CAST(snapshot_after_json AS string) AS snapshot_after_json
    , CAST(matter_id AS decimal(19,0))    AS matter_id
FROM {{ source('source_scms', 'raw_bank_history') }}