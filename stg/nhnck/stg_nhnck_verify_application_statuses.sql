/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_verify_application_statuses
* Program name: Staging NHNCK.VERIFY_APPLICATION_STATUSES
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
    , CAST(application_id AS int)        AS application_id
    , CAST(status_id AS int)             AS status_id
    , CAST(prev_status_id AS int)        AS prev_status_id
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
FROM {{ source('source_nhnck', 'raw_verify_application_statuses') }}