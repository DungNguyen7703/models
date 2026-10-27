/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_digital_certificates
* Program name: Staging NHNCK.DIGITAL_CERTIFICATES
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
    , CAST(subject AS string)       AS subject
    , CAST(company_name AS string)  AS company_name
    , CAST(tax_code AS string)      AS tax_code
    , CAST(email AS string)         AS email
    , CAST(issuer AS string)        AS issuer
    , CAST(serial_number AS string) AS serial_number
    , CAST(valid_from AS date)      AS valid_from
    , CAST(valid_to AS date)        AS valid_to
    , CAST(base64_data AS string)   AS base64_data
    , CAST(thumbprint AS string)    AS thumbprint
    , CAST(full_data AS string)     AS full_data
    , CAST(status AS int)           AS status
    , CAST(created_at AS date)      AS created_at
    , CAST(updated_at AS date)      AS updated_at
    , CAST(created_by AS int)       AS created_by
    , CAST(updated_by AS int)       AS updated_by
FROM {{ source('source_nhnck', 'raw_digital_certificates') }}