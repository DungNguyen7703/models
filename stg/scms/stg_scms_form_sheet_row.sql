/*
*--------------------------------------------------------------------*
* Program code: stg_scms_form_sheet_row
* Program name: Staging SCMS.FORM_SHEET_ROW
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
    , CAST(form_report_id AS int)           AS form_report_id
    , CAST(form_sheet_id AS int)            AS form_sheet_id
    , CAST(row_code AS string)              AS row_code
    , CAST(row_name AS string)              AS row_name
    , CAST(sort_order AS int)               AS sort_order
    , CAST(name_format AS string)           AS name_format
    , CAST(color AS string)                 AS color
    , CAST(alignment AS string)             AS alignment
    , CAST(frozen_row AS int)               AS frozen_row
    , CAST(description AS string)           AS description
    , CAST(active AS int)                   AS active
    , CAST(record_status AS int)            AS record_status
    , CAST(version AS int)                  AS version
    , CAST(last_modified_at_legacy AS date) AS last_modified_at_legacy
    , CAST(legacy_row_code AS string)       AS legacy_row_code
    , CAST(sync_row_code AS string)         AS sync_row_code
    , CAST(hidden_row AS int)               AS hidden_row
    , CAST(hierarchy_level AS int)          AS hierarchy_level
    , CAST(editable AS int)                 AS editable
    , CAST(formula AS string)               AS formula
    , CAST(parent_row_id AS int)            AS parent_row_id
    , CAST(bold AS int)                     AS bold
    , CAST(italic AS int)                   AS italic
    , CAST(row_type AS int)                 AS row_type
    , CAST(background_color AS string)      AS background_color
    , CAST(last_modified_at AS timestamp)   AS last_modified_at
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(last_modified_by AS int)         AS last_modified_by
    , CAST(created_by AS int)               AS created_by
FROM {{ source('source_scms', 'raw_form_sheet_row') }}