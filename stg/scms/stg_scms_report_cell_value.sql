/*
*--------------------------------------------------------------------*
* Program code: stg_scms_report_cell_value
* Program name: Staging SCMS.REPORT_CELL_VALUE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                            AS id
    , CAST(form_report_id AS int)                AS form_report_id
    , CAST(sc_firm_info_id AS int)               AS sc_firm_info_id
    , CAST(member_report_id AS int)              AS member_report_id
    , CAST(form_sheet_cell_id AS int)            AS form_sheet_cell_id
    , CAST(indicator_id AS int)                  AS indicator_id
    , CAST(catalog_name AS string)               AS catalog_name
    , CAST(catalog_id AS string)                 AS catalog_id
    , CAST(catalog_text AS string)               AS catalog_text
    , CAST(form_sheet_id AS int)                 AS form_sheet_id
    , CAST(form_sheet_row_id AS int)             AS form_sheet_row_id
    , CAST(form_sheet_column_id AS int)          AS form_sheet_column_id
    , CAST(row_name AS string)                   AS row_name
    , CAST(column_name AS string)                AS column_name
    , CAST(sheet_name AS string)                 AS sheet_name
    , CAST(row_id AS int)                        AS row_id
    , CAST(version AS int)                       AS version
    , CAST(data_date AS date)                    AS data_date
    , CAST(created_at AS timestamp)              AS created_at
    , CAST(created_by AS int)                    AS created_by
    , CAST(last_modified_at_legacy AS timestamp) AS last_modified_at_legacy
    , CAST(form_periodic_report_id AS int)       AS form_periodic_report_id
    , CAST(report_period_value AS string)        AS report_period_value
    , CAST(report_period AS string)              AS report_period
    , CAST(report_year AS string)                AS report_year
    , CAST(form_sheet_cell_input_id AS int)      AS form_sheet_cell_input_id
    , CAST(submission_status AS int)             AS submission_status
    , CAST(sum_formula AS string)                AS sum_formula
    , CAST(formula AS string)                    AS formula
    , CAST(unit AS int)                          AS unit
    , CAST(format AS string)                     AS format
    , CAST(row_order AS int)                     AS row_order
    , CAST(item_value AS string)                 AS item_value
    , CAST(periodic_report_id AS decimal(19,0))  AS periodic_report_id
    , CAST(note AS string)                       AS note
    , CAST(old_value AS string)                  AS old_value
    , CAST(numeric_value AS decimal(38,2))       AS numeric_value
    , CAST(last_modified_at AS timestamp)        AS last_modified_at
    , CAST(last_modified_by AS int)              AS last_modified_by
FROM {{ source('source_scms', 'raw_report_cell_value') }}