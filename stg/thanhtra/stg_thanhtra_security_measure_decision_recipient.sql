/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_security_measure_decision_recipient
* Program name: Staging THANHTRA.SECURITY_MEASURE_DECISION_RECIPIENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                             AS id
    , CAST(security_measure_decision_id AS string) AS security_measure_decision_id
    , CAST(recipient_type AS string)               AS recipient_type
    , CAST(recipient_name AS string)               AS recipient_name
    , CAST(recipient_reference_id AS string)       AS recipient_reference_id
    , CAST(sent_date AS date)                      AS sent_date
    , CAST(confirmation_status AS string)          AS confirmation_status
    , CAST(confirmed_at AS date)                   AS confirmed_at
    , CAST(confirmed_by AS string)                 AS confirmed_by
    , CAST(created_at AS date)                     AS created_at
    , CAST(last_modified_at AS date)               AS last_modified_at
    , CAST(created_by AS string)                   AS created_by
    , CAST(last_modified_by AS string)             AS last_modified_by
    , CAST(version AS bigint)                      AS version
    , CAST(deleted AS int)                         AS deleted
FROM {{ source('source_thanhtra', 'raw_security_measure_decision_recipient') }}