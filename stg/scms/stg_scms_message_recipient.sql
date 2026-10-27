/*
*--------------------------------------------------------------------*
* Program code: stg_scms_message_recipient
* Program name: Staging SCMS.MESSAGE_RECIPIENT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)           AS id
    , CAST(recipient_id AS int) AS recipient_id
    , CAST(message_id AS int)   AS message_id
FROM {{ source('source_scms', 'raw_message_recipient') }}