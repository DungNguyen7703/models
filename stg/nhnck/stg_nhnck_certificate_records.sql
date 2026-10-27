/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_certificate_records
* Program name: Staging NHNCK.CERTIFICATE_RECORDS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                          AS id
    , CAST(certificate_id AS int)            AS certificate_id
    , CAST(professional_id AS int)           AS professional_id
    , CAST(issue_decision_id AS int)         AS issue_decision_id
    , CAST(revocation_decision_id AS int)    AS revocation_decision_id
    , CAST(certificate_number AS string)     AS certificate_number
    , CAST(issue_date AS date)               AS issue_date
    , CAST(revocation_date AS date)          AS revocation_date
    , CAST(revocation_reason AS string)      AS revocation_reason
    , CAST(status AS int)                    AS status
    , CAST(description AS string)            AS description
    , CAST(created_at AS date)               AS created_at
    , CAST(created_by AS int)                AS created_by
    , CAST(allow_reissue AS int)             AS allow_reissue
    , CAST(professional_full_name AS string) AS professional_full_name
    , CAST(updated_at AS date)               AS updated_at
    , CAST(process_status AS int)            AS process_status
    , CAST(cer_path AS string)               AS cer_path
    , CAST(cancellation_decision_id AS int)  AS cancellation_decision_id
    , CAST(conversion_status AS int)         AS conversion_status
    , CAST(updated_by AS int)                AS updated_by
FROM {{ source('source_nhnck', 'raw_certificate_records') }}