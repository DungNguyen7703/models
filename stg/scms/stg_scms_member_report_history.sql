/*
*--------------------------------------------------------------------*
* Program code: stg_scms_member_report_history
* Program name: Staging SCMS.MEMBER_REPORT_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                      AS id
    , CAST(member_report_id AS int)        AS member_report_id
    , CAST(sc_firm_info_id AS int)         AS sc_firm_info_id
    , CAST(form_report_id AS int)          AS form_report_id
    , CAST(form_periodic_report_id AS int) AS form_periodic_report_id
    , CAST(user_id AS int)                 AS user_id
    , CAST(description AS string)          AS description
    , CAST(reason AS string)               AS reason
    , CAST(submission_time AS string)      AS submission_time
    , CAST(resubmission_reason AS string)  AS resubmission_reason
    , CAST(attachment_path AS string)      AS attachment_path
    , CAST(data_date AS timestamp)         AS data_date
    , CAST(sent_at AS timestamp)           AS sent_at
    , CAST(created_at AS timestamp)        AS created_at
    , CAST(record_status AS int)           AS record_status
    , CAST(version AS int)                 AS version
    , CAST(report_cancelled AS int)        AS report_cancelled
    , CAST(old_data AS string)             AS old_data
    , CAST(new_data AS string)             AS new_data
    , CAST(action AS string)               AS action
    , CAST(ip_address AS string)           AS ip_address
    , CAST(performed_at AS timestamp)      AS performed_at
    , CAST(performed_by AS int)            AS performed_by
    , CAST(performer_name AS string)       AS performer_name
FROM {{ source('source_scms', 'raw_member_report_history') }}