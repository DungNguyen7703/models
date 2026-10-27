/*
*--------------------------------------------------------------------*
* Program code: stg_scms_output_report_parent_child
* Program name: Staging SCMS.OUTPUT_REPORT_PARENT_CHILD
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))               AS id
    , CAST(parent_report_id AS decimal(19,0)) AS parent_report_id
    , CAST(form_report_id AS decimal(19,0))   AS form_report_id
    , CAST(sort_order AS int)                 AS sort_order
FROM {{ source('source_scms', 'raw_output_report_parent_child') }}