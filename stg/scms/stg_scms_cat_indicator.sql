/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_indicator
* Program name: Staging SCMS.CAT_INDICATOR
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                       AS id
    , CAST(indicator_catalog_id AS int)     AS indicator_catalog_id
    , CAST(indicator_code AS string)        AS indicator_code
    , CAST(indicator_name AS string)        AS indicator_name
    , CAST(parent_hierarchy_code AS string) AS parent_hierarchy_code
    , CAST(hierarchy_code AS string)        AS hierarchy_code
    , CAST(hierarchy_level AS int)          AS hierarchy_level
    , CAST(data_type AS int)                AS data_type
    , CAST(active AS int)                   AS active
    , CAST(catalog_level AS string)         AS catalog_level
    , CAST(calculation_method AS int)       AS calculation_method
    , CAST(description AS string)           AS description
    , CAST(created_by AS int)               AS created_by
    , CAST(created_at AS date)              AS created_at
    , CAST(last_modified_by AS int)         AS last_modified_by
    , CAST(last_modified_at AS date)        AS last_modified_at
FROM {{ source('source_scms', 'raw_cat_indicator') }}