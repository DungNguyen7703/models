/*
*--------------------------------------------------------------------*
* Program code: stg_scms_form_indicator_field_meta
* Program name: Staging SCMS.FORM_INDICATOR_FIELD_META
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))             AS id
    , CAST(entity_code AS string)           AS entity_code
    , CAST(field_code AS string)            AS field_code
    , CAST(db_column_name AS string)        AS db_column_name
    , CAST(display_name AS string)          AS display_name
    , CAST(data_type AS string)             AS data_type
    , CAST(relation_type AS string)         AS relation_type
    , CAST(junction_table_name AS string)   AS junction_table_name
    , CAST(main_fk_column AS string)        AS main_fk_column
    , CAST(catalog_table_name AS string)    AS catalog_table_name
    , CAST(catalog_fk_column AS string)     AS catalog_fk_column
    , CAST(catalog_filter_column AS string) AS catalog_filter_column
    , CAST(sort_order AS int)               AS sort_order
    , CAST(record_status AS int)            AS record_status
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(value_source AS string)          AS value_source
    , CAST(string_format AS string)         AS string_format
FROM {{ source('source_scms', 'raw_form_indicator_field_meta') }}