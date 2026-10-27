/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_procedure_forms
* Program name: Staging NHNCK.PROCEDURE_FORMS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)             AS id
    , CAST(procedure_id AS int) AS procedure_id
    , CAST(form_id AS int)      AS form_id
    , CAST(quantity AS int)     AS quantity
FROM {{ source('source_nhnck', 'raw_procedure_forms') }}