/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_verify_certificate_conversion_statuses
* Program name: Staging NHNCK.VERIFY_CERTIFICATE_CONVERSION_STATUSES
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
    , CAST(conversion_request_id AS int) AS conversion_request_id
    , CAST(target_status AS int)         AS target_status
    , CAST(prev_status AS int)           AS prev_status
    , CAST(status AS int)                AS status
    , CAST(reason AS string)             AS reason
    , CAST(spec_reason AS string)        AS spec_reason
    , CAST(org_reason AS string)         AS org_reason
    , CAST(overview_reason AS string)    AS overview_reason
    , CAST(overview_file_path AS string) AS overview_file_path
    , CAST(verified_by AS int)           AS verified_by
    , CAST(created_by AS int)            AS created_by
    , CAST(created_at AS date)           AS created_at
    , CAST(updated_by AS int)            AS updated_by
    , CAST(updated_at AS date)           AS updated_at
FROM {{ source('source_nhnck', 'raw_verify_certificate_conversion_statuses') }}
