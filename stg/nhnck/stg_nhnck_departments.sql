/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_departments
* Program name: Staging NHNCK.DEPARTMENTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                   AS id
    , CAST(unit_id AS int)            AS unit_id
    , CAST(department_code AS string) AS department_code
    , CAST(department_name AS string) AS department_name
    , CAST(sort_order AS int)         AS sort_order
    , CAST(description AS string)     AS description
    , CAST(status AS int)             AS status
    , CAST(ecatalog_id AS string)     AS ecatalog_id
FROM {{ source('source_nhnck', 'raw_departments') }}