/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_professional_trainings
* Program name: Staging NHNCK.PROFESSIONAL_TRAININGS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                  AS id
    , CAST(professional_id AS int)   AS professional_id
    , CAST(start_date AS string)     AS start_date
    , CAST(end_date AS string)       AS end_date
    , CAST(training_place AS string) AS training_place
    , CAST(specialization AS string) AS specialization
    , CAST(awards AS string)         AS awards
    , CAST(disciplines AS string)    AS disciplines
FROM {{ source('source_nhnck', 'raw_professional_trainings') }}