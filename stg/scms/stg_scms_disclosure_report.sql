/*
*--------------------------------------------------------------------*
* Program code: stg_scms_disclosure_report
* Program name: Staging SCMS.DISCLOSURE_REPORT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                               AS id
    , CAST(sc_firm_info_id AS int)                  AS sc_firm_info_id
    , CAST(news_type AS string)                     AS news_type
    , CAST(disclosure_type AS string)               AS disclosure_type
    , CAST(report_period AS string)                 AS report_period
    , CAST(report_year AS string)                   AS report_year
    , CAST(title AS string)                         AS title
    , CAST(disclosure_person_name AS string)        AS disclosure_person_name
    , CAST(disclosure_date AS date)                 AS disclosure_date
    , CAST(error_description AS string)             AS error_description
    , CAST(created_by AS int)                       AS created_by
    , CAST(created_at AS timestamp)                 AS created_at
    , CAST(sent_at AS timestamp)                    AS sent_at
    , CAST(record_status AS int)                    AS record_status
    , CAST(report_period_value AS string)           AS report_period_value
    , CAST(member_report_id AS int)                 AS member_report_id
    , CAST(legacy_news_id AS int)                   AS legacy_news_id
    , CAST(legacy_filename AS string)               AS legacy_filename
    , CAST(legacy_filedata AS string)               AS legacy_filedata
    , CAST(original_disclosure_id AS int)           AS original_disclosure_id
    , CAST(event_type_id AS int)                    AS event_type_id
    , CAST(correction AS int)                       AS correction
    , CAST(cancellation_reason AS string)           AS cancellation_reason
    , CAST(rejection_reason AS string)              AS rejection_reason
    , CAST(cancelled_at AS timestamp)               AS cancelled_at
    , CAST(event_date AS timestamp)                 AS event_date
    , CAST(approved_by AS int)                      AS approved_by
    , CAST(sender_id AS int)                        AS sender_id
    , CAST(cancelled_by AS int)                     AS cancelled_by
    , CAST(late_days AS int)                        AS late_days
    , CAST(disclosure_deadline AS timestamp)        AS disclosure_deadline
    , CAST(updated_at AS timestamp)                 AS updated_at
    , CAST(updated_by AS int)                       AS updated_by
    , CAST(eform_data AS string)                    AS eform_data
    , CAST(sc_firm_adhoc_report_id AS int)          AS sc_firm_adhoc_report_id
    , CAST(periodic_report_id AS int)               AS periodic_report_id
    , CAST(sc_firm_foreign_branch_id AS int)        AS sc_firm_foreign_branch_id
    , CAST(sc_firm_foreign_branch_report_id AS int) AS sc_firm_foreign_branch_report_id
    , CAST(summary AS string)                       AS summary
    , CAST(note AS string)                          AS note
    , CAST(description AS string)                   AS description
    , CAST(import_file_path AS string)              AS import_file_path
    , CAST(import_file_name AS string)              AS import_file_name
    , CAST(import_data AS string)                   AS import_data
    , CAST(import_bm_id AS decimal(19,0))           AS import_bm_id
    , CAST(attachment_path AS string)               AS attachment_path
FROM {{ source('source_scms', 'raw_disclosure_report') }}