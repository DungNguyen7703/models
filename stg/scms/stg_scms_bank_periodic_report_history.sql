/*
*--------------------------------------------------------------------*
* Program code: stg_scms_bank_periodic_report_history
* Program name: Staging SCMS.BANK_PERIODIC_REPORT_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))                      AS id
    , CAST(bank_periodic_report_id AS decimal(19,0)) AS bank_periodic_report_id
    , CAST(performed_at AS timestamp)                AS performed_at
    , CAST(performer_name AS string)                 AS performer_name
    , CAST(action AS string)                         AS action
    , CAST(record_status AS int)                     AS record_status
    , CAST(note AS string)                           AS note
    , CAST(data_file_path AS string)                 AS data_file_path
FROM {{ source('source_scms', 'raw_bank_periodic_report_history') }}