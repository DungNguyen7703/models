/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_organization_report_yearlys
* Program name: Staging NHNCK.ORGANIZATION_REPORT_YEARLYS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                 AS id
    , CAST(organization_id AS int)  AS organization_id
    , CAST(name AS string)          AS name
    , CAST(submission_date AS date) AS submission_date
    , CAST(year AS string)          AS year
    , CAST(type AS string)          AS type
    , CAST(file_path AS string)     AS file_path
    , CAST(status AS int)           AS status
    , CAST(created_at AS date)      AS created_at
    , CAST(updated_at AS date)      AS updated_at
    , CAST(created_by AS int)       AS created_by
    , CAST(updated_by AS int)       AS updated_by
FROM {{ source('source_nhnck', 'raw_organization_report_yearlys') }}