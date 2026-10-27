/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_histories
* Program name: Staging NHNCK.APPLICATION_HISTORIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                 AS id
    , CAST(application_id AS int)   AS application_id
    , CAST(status_id AS int)        AS status_id
    , CAST(title AS string)         AS title
    , CAST(description AS string)   AS description
    , CAST(created_at AS date)      AS created_at
    , CAST(sender_id AS int)        AS sender_id
    , CAST(receiver_id AS int)      AS receiver_id
    , CAST(receiver_name AS string) AS receiver_name
    , CAST(is_rejected AS int)      AS is_rejected
    , CAST(feedback AS string)      AS feedback
    , CAST(updated_at AS date)      AS updated_at
    , CAST(created_by AS int)       AS created_by
    , CAST(updated_by AS int)       AS updated_by
FROM {{ source('source_nhnck', 'raw_application_histories') }}