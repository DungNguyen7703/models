/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_adhoc_report_history
* Program name: Staging SCMS.SC_FIRM_ADHOC_REPORT_HISTORY
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
    , CAST(report_id AS int)          AS report_id
    , CAST(data_file_path AS string)  AS data_file_path
    , CAST(note AS string)            AS note
    , CAST(performer_name AS string)  AS performer_name
    , CAST(action AS string)          AS action
    , CAST(performed_at AS timestamp) AS performed_at
    , CAST(record_status AS int)      AS record_status
FROM {{ source('source_scms', 'raw_sc_firm_adhoc_report_history') }}