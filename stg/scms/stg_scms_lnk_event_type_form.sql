/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_event_type_form
* Program name: Staging SCMS.LNK_EVENT_TYPE_FORM
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
    , CAST(event_type_id AS decimal(19,0))  AS event_type_id
    , CAST(form_report_id AS decimal(19,0)) AS form_report_id
    , CAST(applicable_from AS date)         AS applicable_from
    , CAST(applicable_to AS date)           AS applicable_to
    , CAST(required AS int)                 AS required
    , CAST(sort_order AS int)               AS sort_order
    , CAST(record_status AS int)            AS record_status
FROM {{ source('source_scms', 'raw_lnk_event_type_form') }}