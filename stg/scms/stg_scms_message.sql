/*
*--------------------------------------------------------------------*
* Program code: stg_scms_message
* Program name: Staging SCMS.MESSAGE
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
    , CAST(attachment_path AS string)       AS attachment_path
    , CAST(send_by_email AS int)            AS send_by_email
    , CAST(sent_at AS timestamp)            AS sent_at
    , CAST(sender_id AS int)                AS sender_id
    , CAST(content AS string)               AS content
    , CAST(title AS string)                 AS title
    , CAST(reply_to_message_id AS int)      AS reply_to_message_id
    , CAST(recipient_unit_labels AS string) AS recipient_unit_labels
FROM {{ source('source_scms', 'raw_message') }}