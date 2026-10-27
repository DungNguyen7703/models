/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_professional_work_histories
* Program name: Staging NHNCK.PROFESSIONAL_WORK_HISTORIES
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
    , CAST(professional_id AS int)  AS professional_id
    , CAST(unit_name AS string)     AS unit_name
    , CAST(start_date AS date)      AS start_date
    , CAST(end_date AS date)        AS end_date
    , CAST(workplace AS string)     AS workplace
    , CAST(position_id AS int)      AS position_id
    , CAST(position_name AS string) AS position_name
    , CAST(awards AS string)        AS awards
    , CAST(disciplines AS string)   AS disciplines
    , CAST(created_at AS date)      AS created_at
    , CAST(created_by AS int)       AS created_by
    , CAST(updated_at AS date)      AS updated_at
    , CAST(updated_by AS int)       AS updated_by
FROM {{ source('source_nhnck', 'raw_professional_work_histories') }}