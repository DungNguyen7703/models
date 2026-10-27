/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_fees
* Program name: Staging NHNCK.APPLICATION_FEES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                AS id
    , CAST(application_id AS int)  AS application_id
    , CAST(professional_id AS int) AS professional_id
    , CAST(fee_type AS int)        AS fee_type
    , CAST(content AS string)      AS content
    , CAST(note AS string)         AS note
    , CAST(status AS int)          AS status
    , CAST(request_date AS date)   AS request_date
    , CAST(payment_date AS date)   AS payment_date
    , CAST(expiry_date AS date)    AS expiry_date
    , CAST(fee AS decimal(18,2))   AS fee
    , CAST(file_path AS string)    AS file_path
    , CAST(created_by AS int)      AS created_by
    , CAST(created_at AS date)     AS created_at
    , CAST(updated_by AS int)      AS updated_by
    , CAST(updated_at AS date)     AS updated_at
FROM {{ source('source_nhnck', 'raw_application_fees') }}