/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_department_access
* Program name: Staging NHNCK.DEPARTMENT_ACCESS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                     AS id
    , CAST(department_id AS int)        AS department_id
    , CAST(department_access_id AS int) AS department_access_id
FROM {{ source('source_nhnck', 'raw_department_access') }}