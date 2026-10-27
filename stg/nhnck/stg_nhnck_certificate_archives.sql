/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_certificate_archives
* Program name: Staging NHNCK.CERTIFICATE_ARCHIVES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                              AS id
    , CAST(certificate_id AS int)                AS certificate_id
    , CAST(professional_id AS int)               AS professional_id
    , CAST(certificate_record_id AS int)         AS certificate_record_id
    , CAST(nationality_id AS int)                AS nationality_id
    , CAST(archive_number AS string)             AS archive_number
    , CAST(certificate_number AS string)         AS certificate_number
    , CAST(archive_date AS date)                 AS archive_date
    , CAST(received_date AS date)                AS received_date
    , CAST(recipient AS string)                  AS recipient
    , CAST(identity_number AS string)       AS identity_number
    , CAST(introduction_letter_number AS string) AS introduction_letter_number
    , CAST(introduction_letter AS string)        AS introduction_letter
    , CAST(note AS string)                       AS note
    , CAST(payment_status AS int)                AS payment_status
    , CAST(created_at AS date)                   AS created_at
    , CAST(created_by AS int)                    AS created_by
    , CAST(updated_at AS date)                   AS updated_at
    , CAST(updated_by AS int)                    AS updated_by
FROM {{ source('source_nhnck', 'raw_certificate_archives') }}