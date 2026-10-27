/*
*--------------------------------------------------------------------*
* Program code: stg_scms_permission_data
* Program name: Staging SCMS.PERMISSION_DATA
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
    , CAST(user_id AS int)                AS user_id
    , CAST(entity_type AS string)         AS entity_type
    , CAST(entity_id AS int)              AS entity_id
    , CAST(entity_display_name AS string) AS entity_display_name
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(created_by AS int)             AS created_by
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(last_modified_by AS int)       AS last_modified_by
FROM {{ source('source_scms', 'raw_permission_data') }}