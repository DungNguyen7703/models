/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_certificate_departments
* Program name: Staging NHNCK.CERTIFICATE_DEPARTMENTS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)               AS id
    , CAST(certificate_id AS int) AS certificate_id
    , CAST(department_id AS int)  AS department_id
FROM {{ source('source_nhnck', 'raw_certificate_departments') }}