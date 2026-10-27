/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_documents
* Program name: Staging NHNCK.DOCUMENTS
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
    , CAST(document_code AS string) AS document_code
    , CAST(document_name AS string) AS document_name
    , CAST(reference AS string)     AS reference
    , CAST(created_at AS date)      AS created_at
    , CAST(created_by AS int)       AS created_by
    , CAST(updated_at AS date)      AS updated_at
    , CAST(is_active AS int)        AS is_active
    , CAST(is_original_data AS int) AS is_original_data
    , CAST(sort_order AS int)       AS sort_order
    , CAST(status AS int)           AS status
    , CAST(mcdt_code AS string)     AS mcdt_code
    , CAST(updated_by AS int)       AS updated_by
FROM {{ source('source_nhnck', 'raw_documents') }}