/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_exam_sessions
* Program name: Staging NHNCK.EXAM_SESSIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                          AS id
    , CAST(name AS string)                   AS name
    , CAST(code AS string)                   AS code
    , CAST(session_ AS int)                  AS session_
    , CAST(year AS int)                      AS year
    , CAST(organizing_unit AS string)        AS organizing_unit
    , CAST(application_start_date AS string) AS application_start_date
    , CAST(application_end_date AS string)   AS application_end_date
    , CAST(exam_start_date AS string)        AS exam_start_date
    , CAST(exam_end_date AS string)          AS exam_end_date
    , CAST(file_path AS string)              AS file_path
    , CAST(noti_date AS string)              AS noti_date
    , CAST(exam_locations AS string)         AS exam_locations
    , CAST(submission_methods AS string)     AS submission_methods
    , CAST(status AS int)                    AS status
    , CAST(created_at AS date)               AS created_at
    , CAST(updated_at AS date)               AS updated_at
    , CAST(created_by AS int)                AS created_by
    , CAST(updated_by AS int)                AS updated_by
    , CAST(decision_id AS int)               AS decision_id
    , CAST(bank_id AS int)                   AS bank_id
    , CAST(bank_account_number AS string)    AS bank_account_number
    , CAST(bank_account_name AS string)      AS bank_account_name
FROM {{ source('source_nhnck', 'raw_exam_sessions') }}