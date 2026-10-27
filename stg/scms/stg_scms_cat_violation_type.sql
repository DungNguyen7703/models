/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_violation_type
* Program name: Staging SCMS.CAT_VIOLATION_TYPE
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
    , CAST(violation_type_code AS string) AS violation_type_code
    , CAST(violation_type_name AS string) AS violation_type_name
    , CAST(last_modified_at AS date)      AS last_modified_at
    , CAST(ecatalog_id AS string)         AS ecatalog_id
FROM {{ source('source_scms', 'raw_cat_violation_type') }}