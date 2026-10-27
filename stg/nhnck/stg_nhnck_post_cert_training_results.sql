/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_post_cert_training_results
* Program name: Staging NHNCK.POST_CERT_TRAINING_RESULTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                         AS id
    , CAST(professional_id AS int)          AS professional_id
    , CAST(training_course_id AS int)       AS training_course_id
    , CAST(start_date AS date)              AS start_date
    , CAST(end_date AS date)                AS end_date
    , CAST(training_hours AS int)           AS training_hours
    , CAST(result_status AS int)            AS result_status
    , CAST(classification_result AS string) AS classification_result
    , CAST(note AS string)                  AS note
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(created_by AS int)               AS created_by
    , CAST(updated_at AS timestamp)         AS updated_at
    , CAST(updated_by AS int)               AS updated_by
FROM {{ source('source_nhnck', 'raw_post_cert_training_results') }}