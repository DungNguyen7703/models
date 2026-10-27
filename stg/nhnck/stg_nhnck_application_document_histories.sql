/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_document_histories
* Program name: Staging NHNCK.APPLICATION_DOCUMENT_HISTORIES
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
    , CAST(application_id AS int) AS application_id
    , CAST(document_id AS int)    AS document_id
    , CAST(is_invalid AS int)     AS is_invalid
    , CAST(is_incomplete AS int)  AS is_incomplete
    , CAST(description AS string) AS description
    , CAST(status AS int)         AS status
    , CAST(created_at AS date)    AS created_at
    , CAST(updated_by AS int)     AS updated_by
    , CAST(updated_at AS date)    AS updated_at
    , CAST(created_by AS int)     AS created_by
FROM {{ source('source_nhnck', 'raw_application_document_histories') }}