/*
*--------------------------------------------------------------------*
* Program code: stg_scms_form_report_history
* Program name: Staging SCMS.FORM_REPORT_HISTORY
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
    , CAST(form_id AS int)            AS form_id
    , CAST(active AS int)             AS active
    , CAST(performed_at AS timestamp) AS performed_at
    , CAST(action AS string)          AS action
    , CAST(version AS int)            AS version
    , CAST(performer_name AS int)     AS performer_name
    , CAST(next_form_id AS int)       AS next_form_id
FROM {{ source('source_scms', 'raw_form_report_history') }}