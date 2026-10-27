/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_specialization_courses
* Program name: Staging NHNCK.SPECIALIZATION_COURSES
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
    , CAST(specialization_id AS int) AS specialization_id
    , CAST(academic_year AS int)     AS academic_year
    , CAST(course_code AS string)    AS course_code
    , CAST(course_name AS string)    AS course_name
    , CAST(created_at AS date)       AS created_at
    , CAST(created_by AS int)        AS created_by
    , CAST(updated_at AS date)       AS updated_at
    , CAST(updated_by AS int)        AS updated_by
    , CAST(status AS int)            AS status
    , CAST(exam_date_from AS date)   AS exam_date_from
    , CAST(exam_date_to AS date)     AS exam_date_to
    , CAST(address AS string)        AS address
    , CAST(province_id AS int)       AS province_id
FROM {{ source('source_nhnck', 'raw_specialization_courses') }}