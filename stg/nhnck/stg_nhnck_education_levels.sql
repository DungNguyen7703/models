/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_education_levels
* Program name: Staging NHNCK.EDUCATION_LEVELS
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
    , CAST(level_name AS string)    AS level_name
    , CAST(description AS string)   AS description
    , CAST(is_displayed AS int)     AS is_displayed
    , CAST(is_original_data AS int) AS is_original_data
    , CAST(status AS int)           AS status
    , CAST(updated_at AS date)      AS updated_at
    , CAST(created_at AS date)      AS created_at
    , CAST(created_by AS int)       AS created_by
    , CAST(updated_by AS int)       AS updated_by
FROM {{ source('source_nhnck', 'raw_education_levels') }}