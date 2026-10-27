/*
*--------------------------------------------------------------------*
* Program code: stg_scms_member_report_processing
* Program name: Staging SCMS.MEMBER_REPORT_PROCESSING
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                 AS id
    , CAST(member_report_id AS int)   AS member_report_id
    , CAST(processor_name AS string)  AS processor_name
    , CAST(processing_date AS date)   AS processing_date
    , CAST(reason AS string)          AS reason
    , CAST(last_modified_at AS date)  AS last_modified_at
    , CAST(attachment_path AS string) AS attachment_path
    , CAST(record_status AS int)      AS record_status
    , CAST(version AS int)            AS version
    , CAST(created_at AS timestamp)   AS created_at
    , CAST(processor_id AS int)       AS processor_id
    , CAST(content AS string)         AS content
    , CAST(status_after AS int)       AS status_after
    , CAST(status_before AS int)      AS status_before
FROM {{ source('source_scms', 'raw_member_report_processing') }}