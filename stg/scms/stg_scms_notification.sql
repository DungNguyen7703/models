/*
*--------------------------------------------------------------------*
* Program code: stg_scms_notification
* Program name: Staging SCMS.NOTIFICATION
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                       AS id
    , CAST(title AS string)                 AS title
    , CAST(content AS string)               AS content
    , CAST(link_url AS string)              AS link_url
    , CAST(recipient_list AS string)        AS recipient_list
    , CAST(viewed_by_list AS string)        AS viewed_by_list
    , CAST(created_by AS int)               AS created_by
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(record_status AS int)            AS record_status
    , CAST(recipient_id AS decimal(19,0))   AS recipient_id
    , CAST(notification_type AS int)        AS notification_type
    , CAST(path_url AS string)              AS path_url
    , CAST(read AS int)                     AS read
    , CAST(read_at AS timestamp)            AS read_at
    , CAST(ref_id AS decimal(19,0))         AS ref_id
    , CAST(ref_type AS string)              AS ref_type
    , CAST(external_notice_id AS string)    AS external_notice_id
    , CAST(company_code AS string)          AS company_code
    , CAST(confirm_callback_url AS string)  AS confirm_callback_url
    , CAST(proactive_notice_type AS string) AS proactive_notice_type
    , CAST(priority AS string)              AS priority
    , CAST(sender_name AS string)           AS sender_name
    , CAST(confirmed AS int)                AS confirmed
    , CAST(confirmed_at AS timestamp)       AS confirmed_at
    , CAST(confirmed_by AS string)          AS confirmed_by
    , CAST(external_payload_json AS string) AS external_payload_json
FROM {{ source('source_scms', 'raw_notification') }}