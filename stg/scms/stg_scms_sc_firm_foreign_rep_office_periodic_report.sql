/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_foreign_rep_office_periodic_report
* Program name: Staging SCMS.SC_FIRM_FOREIGN_REP_OFFICE_PERIODIC_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                            AS id
    , CAST(sc_firm_foreign_rep_office_id AS int) AS sc_firm_foreign_rep_office_id
    , CAST(report_name AS string)                AS report_name
    , CAST(report_year AS int)                   AS report_year
    , CAST(period AS int)                        AS period
    , CAST(event_type_id AS int)                 AS event_type_id
    , CAST(category AS string)                   AS category
    , CAST(event_date AS date)                   AS event_date
    , CAST(summary AS string)                    AS summary
    , CAST(document_number AS string)            AS document_number
    , CAST(document_date AS date)                AS document_date
    , CAST(note AS string)                       AS note
    , CAST(submission_deadline AS date)          AS submission_deadline
    , CAST(sent_at AS timestamp)                 AS sent_at
    , CAST(import_file_path AS string)           AS import_file_path
    , CAST(eform_data AS string)                 AS eform_data
    , CAST(record_status AS int)                 AS record_status
    , CAST(cancellation_reason AS string)        AS cancellation_reason
    , CAST(cancelled_by AS int)                  AS cancelled_by
    , CAST(cancelled_at AS timestamp)            AS cancelled_at
    , CAST(start_date AS date)                   AS start_date
    , CAST(end_date AS date)                     AS end_date
    , CAST(report_period AS string)              AS report_period
    , CAST(quarter AS int)                       AS quarter
    , CAST(report_month AS int)                  AS report_month
    , CAST(submission_deadline_at AS timestamp)  AS submission_deadline_at
    , CAST(attachment_path AS string)            AS attachment_path
    , CAST(previous_submit_status AS int)        AS previous_submit_status
FROM {{ source('source_scms', 'raw_sc_firm_foreign_rep_office_periodic_report') }}