/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_exam_details
* Program name: Staging NHNCK.EXAM_DETAILS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                      AS id
    , CAST(professional_id AS int)       AS professional_id
    , CAST(certificate_id AS int)        AS certificate_id
    , CAST(exam_session_id AS int)       AS exam_session_id
    , CAST(sequence_number AS int)       AS sequence_number
    , CAST(exam_number AS string)        AS exam_number
    , CAST(law_score AS int)             AS law_score
    , CAST(law_result AS int)            AS law_result
    , CAST(specialization_score AS int)  AS specialization_score
    , CAST(specialization_result AS int) AS specialization_result
    , CAST(result AS int)                AS result
    , CAST(note AS string)               AS note
    , CAST(created_at AS date)           AS created_at
    , CAST(updated_at AS date)           AS updated_at
    , CAST(created_by AS int)            AS created_by
    , CAST(updated_by AS int)            AS updated_by
    , CAST(application_id AS int)        AS application_id
FROM {{ source('source_nhnck', 'raw_exam_details') }}