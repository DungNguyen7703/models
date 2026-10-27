/*
*--------------------------------------------------------------------*
* Program code: stg_scms_form_report_periodic
* Program name: Staging SCMS.FORM_REPORT_PERIODIC
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
    , CAST(form_report_id AS int)         AS form_report_id
    , CAST(report_period AS string)       AS report_period
    , CAST(period_num AS int)             AS period_num
    , CAST(latest_submission_time AS int) AS latest_submission_time
    , CAST(unit AS int)                   AS unit
    , CAST(preparation_time AS int)       AS preparation_time
    , CAST(submission_hour AS int)        AS submission_hour
    , CAST(expected_insert_date AS date)  AS expected_insert_date
    , CAST(active AS int)                 AS active
    , CAST(record_status AS int)          AS record_status
    , CAST(note AS string)                AS note
    , CAST(created_by AS int)             AS created_by
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(on_day AS int)                 AS on_day
    , CAST(insert_value AS string)        AS insert_value
    , CAST(prev_form_periodic_id AS int)  AS prev_form_periodic_id
    , CAST(legacy_report_id AS string)    AS legacy_report_id
FROM {{ source('source_scms', 'raw_form_report_periodic') }}