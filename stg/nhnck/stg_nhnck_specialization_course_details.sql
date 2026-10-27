/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_specialization_course_details
* Program name: Staging NHNCK.SPECIALIZATION_COURSE_DETAILS
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
    , CAST(specialization_course_id AS int) AS specialization_course_id
    , CAST(professional_id AS int)          AS professional_id
    , CAST(exam_number AS string)           AS exam_number
    , CAST(full_name AS string)             AS full_name
    , CAST(birth_date AS date)              AS birth_date
    , CAST(permanent_country_id AS int)     AS permanent_country_id
    , CAST(permanent_province_id AS int)    AS permanent_province_id
    , CAST(permanent_district_id AS int)    AS permanent_district_id
    , CAST(place_of_birth AS string)        AS place_of_birth
    , CAST(identity_type AS int)            AS identity_type
    , CAST(identity_number AS string)  AS identity_number
    , CAST(identity_issue_date AS date)     AS identity_issue_date
    , CAST(identity_issue_place AS string)  AS identity_issue_place
    , CAST(created_at AS date)              AS created_at
    , CAST(created_by AS int)               AS created_by
    , CAST(updated_at AS date)              AS updated_at
    , CAST(updated_by AS int)               AS updated_by
    , CAST(description AS string)           AS description
    , CAST(exam_score AS double)            AS exam_score
    , CAST(result AS int)                   AS result
    , CAST(status AS int)                   AS status
    , CAST(note AS string)                  AS note
    , CAST(specialization_id AS int)        AS specialization_id
    , CAST(assignee_id AS int)              AS assignee_id
FROM {{ source('source_nhnck', 'raw_specialization_course_details') }}