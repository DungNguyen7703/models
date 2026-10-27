/*
*--------------------------------------------------------------------*
* Program code: stg_scms_document_storage
* Program name: Staging SCMS.DOCUMENT_STORAGE
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
    , CAST(company_name AS string)    AS company_name
    , CAST(folder_id AS int)          AS folder_id
    , CAST(attachment_path AS string) AS attachment_path
    , CAST(note AS string)            AS note
    , CAST(entry_date AS date)        AS entry_date
FROM {{ source('source_scms', 'raw_document_storage') }}