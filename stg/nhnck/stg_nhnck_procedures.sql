/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_procedures
* Program name: Staging NHNCK.PROCEDURES
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
    , CAST(procedure_type AS int)         AS procedure_type
    , CAST(image AS string)               AS image
    , CAST(title AS string)               AS title
    , CAST(content AS string)             AS content
    , CAST(processing_time AS string)     AS processing_time
    , CAST(target_audience AS string)     AS target_audience
    , CAST(implementing_agency AS string) AS implementing_agency
    , CAST(outcome AS string)             AS outcome
    , CAST(fee AS string)                 AS fee
    , CAST(requirements AS string)        AS requirements
    , CAST(created_at AS date)            AS created_at
    , CAST(created_by AS int)             AS created_by
    , CAST(updated_at AS date)            AS updated_at
    , CAST(status AS int)                 AS status
    , CAST(is_featured AS int)            AS is_featured
    , CAST(reason AS string)              AS reason
    , CAST(updated_by AS int)             AS updated_by
FROM {{ source('source_nhnck', 'raw_procedures') }}