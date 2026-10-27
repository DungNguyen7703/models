/*
*--------------------------------------------------------------------*
* Program code: stg_scms_legal_document_lookup
* Program name: Staging SCMS.LEGAL_DOCUMENT_LOOKUP
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                   AS id
    , CAST(document_number AS string)   AS document_number
    , CAST(content_summary AS string)   AS content_summary
    , CAST(attachment_path AS string)   AS attachment_path
    , CAST(created_by AS int)           AS created_by
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(issued_date AS timestamp)    AS issued_date
    , CAST(record_status AS int)        AS record_status
    , CAST(effective_date AS timestamp) AS effective_date
FROM {{ source('source_scms', 'raw_legal_document_lookup') }}