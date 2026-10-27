/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_statistic
* Program name: Staging SCMS.CAT_STATISTIC
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                AS id
    , CAST(statistic_code AS string) AS statistic_code
    , CAST(catalog_name AS string)   AS catalog_name
    , CAST(table_name AS string)     AS table_name
    , CAST(field_name AS string)     AS field_name
    , CAST(last_modified_at AS date) AS last_modified_at
FROM {{ source('source_scms', 'raw_cat_statistic') }}