/*
*--------------------------------------------------------------------*
* Program code: stg_scms_report_dynamic_row_value
* Program name: Staging SCMS.REPORT_DYNAMIC_ROW_VALUE
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
    , CAST(member_report_id AS int)       AS member_report_id
    , CAST(form_report_id AS int)         AS form_report_id
    , CAST(form_sheet_row_id AS int)      AS form_sheet_row_id
    , CAST(sc_firm_info_id AS int)        AS sc_firm_info_id
    , CAST(item_value AS string)          AS item_value
    , CAST(data_json AS string)           AS data_json
    , CAST(periodic_report_id AS int)     AS periodic_report_id
    , CAST(form_sheet_id AS int)          AS form_sheet_id
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_by AS int)       AS last_modified_by
    , CAST(created_by AS int)             AS created_by
    , CAST(row_count AS int)              AS row_count
    , CAST(record_status AS int)          AS record_status
FROM {{ source('source_scms', 'raw_report_dynamic_row_value') }}