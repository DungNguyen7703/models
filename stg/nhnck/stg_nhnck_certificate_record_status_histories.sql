/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_certificate_record_status_histories
* Program name: Staging NHNCK.CERTIFICATE_RECORD_STATUS_HISTORIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                      AS id
    , CAST(certificate_record_id AS int) AS certificate_record_id
    , CAST(update_type AS string)        AS update_type
    , CAST(old_status AS int)            AS old_status
    , CAST(new_status AS int)            AS new_status
    , CAST(decision_id AS int)           AS decision_id
    , CAST(reason AS string)             AS reason
    , CAST(created_by AS int)            AS created_by
    , CAST(created_at AS date)           AS created_at
    , CAST(updated_at AS date)           AS updated_at
    , CAST(updated_by AS int)            AS updated_by
FROM {{ source('source_nhnck', 'raw_certificate_record_status_histories') }}