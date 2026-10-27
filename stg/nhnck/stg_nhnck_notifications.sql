/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_notifications
* Program name: Staging NHNCK.NOTIFICATIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)              AS id
    , CAST(action_type AS int)   AS action_type
    , CAST(type AS int)          AS type
    , CAST(is_read AS int)       AS is_read
    , CAST(content AS string)    AS content
    , CAST(link AS string)       AS link
    , CAST(receiver_id AS int)   AS receiver_id
    , CAST(sent_at AS timestamp) AS sent_at
    , CAST(read_at AS timestamp) AS read_at
FROM {{ source('source_nhnck', 'raw_notifications') }}