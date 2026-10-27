/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_re_exams
* Program name: Staging NHNCK.APPLICATION_RE_EXAMS
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
    , CAST(application_id AS int)    AS application_id
    , CAST(exam_detail_id AS int)    AS exam_detail_id
    , CAST(re_application_id AS int) AS re_application_id
    , CAST(status AS int)            AS status
    , CAST(created_at AS date)       AS created_at
    , CAST(updated_at AS date)       AS updated_at
    , CAST(created_by AS int)        AS created_by
    , CAST(updated_by AS int)        AS updated_by
FROM {{ source('source_nhnck', 'raw_application_re_exams') }}