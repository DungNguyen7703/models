/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_certificates
* Program name: Staging NHNCK.CERTIFICATES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                    AS id
    , CAST(certificate_code AS string) AS certificate_code
    , CAST(certificate_name AS string) AS certificate_name
    , CAST(description AS string)      AS description
    , CAST(created_at AS date)         AS created_at
    , CAST(updated_at AS date)         AS updated_at
    , CAST(is_displayed AS int)        AS is_displayed
    , CAST(sort_order AS int)          AS sort_order
    , CAST(is_original_data AS int)    AS is_original_data
    , CAST(processing_days AS int)     AS processing_days
    , CAST(status AS int)              AS status
    , CAST(created_by AS int)          AS created_by
    , CAST(updated_by AS int)          AS updated_by
FROM {{ source('source_nhnck', 'raw_certificates') }}