/*
*--------------------------------------------------------------------*
* Program code: stg_scms_document_folder
* Program name: Staging SCMS.DOCUMENT_FOLDER
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)             AS id
    , CAST(folder_name AS string) AS folder_name
    , CAST(description AS string) AS description
    , CAST(user_id AS int)        AS user_id
FROM {{ source('source_scms', 'raw_document_folder') }}