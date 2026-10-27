/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_supplements
* Program name: Staging NHNCK.APPLICATION_SUPPLEMENTS
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
    , CAST(application_id AS int)   AS application_id
    , CAST(supplement_date AS date) AS supplement_date
    , CAST(content AS string)       AS content
    , CAST(supplemented_by AS int)  AS supplemented_by
    , CAST(created_at AS date)      AS created_at
    , CAST(updated_at AS date)      AS updated_at
    , CAST(created_by AS int)       AS created_by
    , CAST(updated_by AS int)       AS updated_by
FROM {{ source('source_nhnck', 'raw_application_supplements') }}