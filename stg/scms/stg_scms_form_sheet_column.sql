/*
*--------------------------------------------------------------------*
* Program code: stg_scms_form_sheet_column
* Program name: Staging SCMS.FORM_SHEET_COLUMN
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
    , CAST(column_code AS string)           AS column_code
    , CAST(column_name AS string)           AS column_name
    , CAST(sort_order AS int)               AS sort_order
    , CAST(name_format AS string)           AS name_format
    , CAST(color AS string)                 AS color
    , CAST(alignment AS string)             AS alignment
    , CAST(frozen_column AS int)            AS frozen_column
    , CAST(locked_column AS int)            AS locked_column
    , CAST(description AS string)           AS description
    , CAST(last_modified_at_legacy AS date) AS last_modified_at_legacy
    , CAST(active AS int)                   AS active
    , CAST(version AS int)                  AS version
    , CAST(legacy_column_code AS string)    AS legacy_column_code
    , CAST(sync_column_code AS string)      AS sync_column_code
    , CAST(hidden_column AS int)            AS hidden_column
    , CAST(required AS int)                 AS required
    , CAST(editable AS int)                 AS editable
    , CAST(formula AS string)               AS formula
    , CAST(format AS string)                AS format
    , CAST(width AS int)                    AS width
    , CAST(data_type AS string)             AS data_type
    , CAST(last_modified_at AS timestamp)   AS last_modified_at
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(last_modified_by AS int)         AS last_modified_by
    , CAST(created_by AS int)               AS created_by
    , CAST(record_status AS int)            AS record_status
FROM {{ source('source_scms', 'raw_form_sheet_column') }}