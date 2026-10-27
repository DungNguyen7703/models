/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_procedure_documents
* Program name: Staging NHNCK.PROCEDURE_DOCUMENTS
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
    , CAST(document_id AS int)  AS document_id
FROM {{ source('source_nhnck', 'raw_procedure_documents') }}