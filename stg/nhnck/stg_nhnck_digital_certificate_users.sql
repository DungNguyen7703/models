/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_digital_certificate_users
* Program name: Staging NHNCK.DIGITAL_CERTIFICATE_USERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                       AS id
    , CAST(digital_certificate_id AS int) AS digital_certificate_id
    , CAST(user_id AS int)                AS user_id
    , CAST(role AS string)                AS role
    , CAST(status AS int)                 AS status
    , CAST(notes AS string)               AS notes
    , CAST(created_at AS date)            AS created_at
    , CAST(updated_at AS date)            AS updated_at
    , CAST(created_by AS int)             AS created_by
    , CAST(updated_by AS int)             AS updated_by
FROM {{ source('source_nhnck', 'raw_digital_certificate_users') }}