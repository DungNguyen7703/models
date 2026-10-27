/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_mcdt_result_outbox
* Program name: Staging NHNCK.MCDT_RESULT_OUTBOX
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)               AS id
    , CAST(application_id AS int) AS application_id
    , CAST(sender_identity AS string) AS sender_identity
    , CAST(status AS string)      AS status
    , CAST(attempts AS int)       AS attempts
    , CAST(next_retry_at AS date) AS next_retry_at
    , CAST(last_error AS string)  AS last_error
    , CAST(created_at AS date)    AS created_at
    , CAST(updated_at AS date)    AS updated_at
FROM {{ source('source_nhnck', 'raw_mcdt_result_outbox') }}
