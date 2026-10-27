/*
*--------------------------------------------------------------------*
* Program code: stg_scms_permission_input_report_event
* Program name: Staging SCMS.PERMISSION_INPUT_REPORT_EVENT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                         AS id
    , CAST(permission_input_report_id AS int) AS permission_input_report_id
    , CAST(event_type_id AS int)              AS event_type_id
FROM {{ source('source_scms', 'raw_permission_input_report_event') }}