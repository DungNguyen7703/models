/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_violations
* Program name: Staging NHNCK.VIOLATIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                        AS id
    , CAST(professional_id AS int)         AS professional_id
    , CAST(full_name AS string)            AS full_name
    , CAST(birth_date AS date)             AS birth_date
    , CAST(identity_number AS string) AS identity_number
    , CAST(note AS string)                 AS note
    , CAST(created_by AS int)              AS created_by
    , CAST(created_at AS date)             AS created_at
    , CAST(decision_id AS int)             AS decision_id
    , CAST(type AS int)                    AS type
    , CAST(status AS int)                  AS status
    , CAST(updated_by AS int)              AS updated_by
    , CAST(updated_at AS date)             AS updated_at
FROM {{ source('source_nhnck', 'raw_violations') }}