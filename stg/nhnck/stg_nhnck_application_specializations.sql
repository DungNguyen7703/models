/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_specializations
* Program name: Staging NHNCK.APPLICATION_SPECIALIZATIONS
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
    , CAST(specialization_id AS int) AS specialization_id
    , CAST(issue_date AS date)       AS issue_date
    , CAST(issue_place AS string)    AS issue_place
    , CAST(status AS int)            AS status
    , CAST(note AS string)           AS note
    , CAST(assignee_id AS int)       AS assignee_id
    , CAST(appraisaled_at AS date)   AS appraisaled_at
    , CAST(created_by AS int)        AS created_by
    , CAST(created_at AS date)       AS created_at
    , CAST(updated_at AS date)       AS updated_at
    , CAST(files AS string)          AS files
    , CAST(updated_by AS int)        AS updated_by
FROM {{ source('source_nhnck', 'raw_application_specializations') }}