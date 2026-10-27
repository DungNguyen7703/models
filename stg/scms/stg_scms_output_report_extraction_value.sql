/*
*--------------------------------------------------------------------*
* Program code: stg_scms_output_report_extraction_value
* Program name: Staging SCMS.OUTPUT_REPORT_EXTRACTION_VALUE
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
    , CAST(output_report_extraction_id AS int) AS output_report_extraction_id
    , CAST(form_report_id AS int)              AS form_report_id
    , CAST(form_sheet_id AS int)               AS form_sheet_id
    , CAST(form_sheet_row_id AS int)           AS form_sheet_row_id
    , CAST(form_sheet_column_id AS int)        AS form_sheet_column_id
    , CAST(form_sheet_cell_id AS int)          AS form_sheet_cell_id
    , CAST(row_id AS int)                      AS row_id
    , CAST(item_value AS string)               AS item_value
    , CAST(audited_report_id AS int)           AS audited_report_id
    , CAST(report_period AS string)            AS report_period
    , CAST(result AS string)                   AS result
    , CAST(export_file_path AS string)         AS export_file_path
    , CAST(error_message AS string)            AS error_message
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(user_id AS int)                     AS user_id
    , CAST(record_count AS int)                AS record_count
    , CAST(input_parameter AS string)          AS input_parameter
    , CAST(execution_time AS decimal(19,0))    AS execution_time
    , CAST(record_status AS int)               AS record_status
FROM {{ source('source_scms', 'raw_output_report_extraction_value') }}