/*
*--------------------------------------------------------------------*
* Program code: stg_scms_permission_output_report_form
* Program name: Staging SCMS.PERMISSION_OUTPUT_REPORT_FORM
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
    , CAST(permission_output_report_id AS int) AS permission_output_report_id
    , CAST(form_report_id AS int)              AS form_report_id
FROM {{ source('source_scms', 'raw_permission_output_report_form') }}