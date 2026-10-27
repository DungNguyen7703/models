/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_certificate_conversion_requests
* Program name: Staging NHNCK.CERTIFICATE_CONVERSION_REQUESTS
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
    , CAST(status AS int)                AS status
    , CAST(notes AS string)              AS notes
    , CAST(processed_at AS date)         AS processed_at
    , CAST(processed_by AS int)          AS processed_by
    , CAST(created_at AS date)           AS created_at
    , CAST(created_by AS int)            AS created_by
    , CAST(updated_at AS date)           AS updated_at
    , CAST(updated_by AS int)            AS updated_by
    , CAST(assignee_id AS int)           AS assignee_id
    , CAST(info_verify_id AS int)        AS info_verify_id
    , CAST(request_payload AS string)    AS request_payload
FROM {{ source('source_nhnck', 'raw_certificate_conversion_requests') }}