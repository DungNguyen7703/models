/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_experiences
* Program name: Staging NHNCK.APPLICATION_EXPERIENCES
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
    , CAST(application_id AS int)           AS application_id
    , CAST(document_id AS int)              AS document_id
    , CAST(work_duration AS int)            AS work_duration
    , CAST(organization_id AS int)          AS organization_id
    , CAST(organization_name AS string)     AS organization_name
    , CAST(department_name AS string)       AS department_name
    , CAST(insurance_number AS string)      AS insurance_number
    , CAST(labor_contract AS string)        AS labor_contract
    , CAST(director_confirmation AS string) AS director_confirmation
    , CAST(note AS string)                  AS note
    , CAST(total_duration AS int)           AS total_duration
    , CAST(start_date AS date)              AS start_date
    , CAST(end_date AS date)                AS end_date
    , CAST(position AS string)              AS position
FROM {{ source('source_nhnck', 'raw_application_experiences') }}