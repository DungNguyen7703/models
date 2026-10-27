/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_alert
* Program name: Staging SCMS.CAT_ALERT
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
    , CAST(form_report_id AS int)     AS form_report_id
    , CAST(form_sheet_cell_id AS int) AS form_sheet_cell_id
    , CAST(alert_code AS string)      AS alert_code
    , CAST(alert_name AS string)      AS alert_name
    , CAST(formula AS string)         AS formula
    , CAST(condition AS string)       AS condition
    , CAST(item_value AS string)      AS item_value
    , CAST(hierarchy_level AS int)    AS hierarchy_level
    , CAST(description AS string)     AS description
    , CAST(start_date AS date)        AS start_date
    , CAST(end_date AS date)          AS end_date
    , CAST(created_at AS date)        AS created_at
    , CAST(created_by AS int)         AS created_by
    , CAST(last_modified_at AS date)  AS last_modified_at
    , CAST(last_modified_by AS int)   AS last_modified_by
    , CAST(deleted AS int)            AS deleted
    , CAST(record_status AS int)      AS record_status
FROM {{ source('source_scms', 'raw_cat_alert') }}