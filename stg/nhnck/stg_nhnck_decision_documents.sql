/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_decision_documents
* Program name: Staging NHNCK.DECISION_DOCUMENTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                   AS id
    , CAST(decision_id AS int)        AS decision_id
    , CAST(type AS int)               AS type
    , CAST(decision_number AS string) AS decision_number
    , CAST(position AS string)        AS position
    , CAST(file_path AS string)       AS file_path
    , CAST(signed_by AS string)       AS signed_by
    , CAST(signed_date AS date)       AS signed_date
    , CAST(status AS int)             AS status
    , CAST(created_at AS date)        AS created_at
    , CAST(updated_at AS date)        AS updated_at
    , CAST(created_by AS int)         AS created_by
    , CAST(updated_by AS int)         AS updated_by
FROM {{ source('source_nhnck', 'raw_decision_documents') }}