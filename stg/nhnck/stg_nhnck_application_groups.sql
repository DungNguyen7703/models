/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_groups
* Program name: Staging NHNCK.APPLICATION_GROUPS
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
    , CAST(group_name AS string)         AS group_name
    , CAST(description AS string)        AS description
    , CAST(status AS int)                AS status
    , CAST(decision_id AS int)           AS decision_id
    , CAST(group_created_date AS date)   AS group_created_date
    , CAST(group_completed_date AS date) AS group_completed_date
    , CAST(notes AS string)              AS notes
    , CAST(application_count AS int)     AS application_count
    , CAST(created_at AS date)           AS created_at
    , CAST(updated_at AS date)           AS updated_at
    , CAST(created_by AS int)            AS created_by
    , CAST(updated_by AS int)            AS updated_by
    , CAST(application_type AS int)      AS application_type
    , CAST(submited_date AS date)        AS submited_date
    , CAST(submited_by AS int)           AS submited_by
FROM {{ source('source_nhnck', 'raw_application_groups') }}