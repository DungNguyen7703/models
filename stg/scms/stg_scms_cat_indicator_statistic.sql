/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_indicator_statistic
* Program name: Staging SCMS.CAT_INDICATOR_STATISTIC
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                          AS id
    , CAST(indicator_id AS int)                AS indicator_id
    , CAST(statistic_catalog_id AS int)        AS statistic_catalog_id
    , CAST(catalog_id AS int)                  AS catalog_id
    , CAST(statistic_indicator_code AS string) AS statistic_indicator_code
    , CAST(statistic_indicator_name AS string) AS statistic_indicator_name
    , CAST(last_modified_at AS date)           AS last_modified_at
FROM {{ source('source_scms', 'raw_cat_indicator_statistic') }}