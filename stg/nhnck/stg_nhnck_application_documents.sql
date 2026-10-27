/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_documents
* Program name: Staging NHNCK.APPLICATION_DOCUMENTS
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
    , CAST(application_id AS int)   AS application_id
    , CAST(document_id AS int)      AS document_id
    , CAST(description AS string)   AS description
    , CAST(status AS int)           AS status
    , CAST(assignee_id AS int)      AS assignee_id
    , CAST(files AS string)         AS files
    , CAST(document_name AS string) AS document_name
    , CAST(note AS string)          AS note
    , CAST(created_at AS date)      AS created_at
    , CAST(appraisaled_at AS date)  AS appraisaled_at
    , CAST(updated_at AS date)      AS updated_at
    , CAST(created_by AS int)       AS created_by
    , CAST(updated_by AS int)       AS updated_by
FROM {{ source('source_nhnck', 'raw_application_documents') }}