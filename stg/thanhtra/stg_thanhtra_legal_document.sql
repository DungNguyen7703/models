/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_legal_document
* Program name: Staging THANHTRA.LEGAL_DOCUMENT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                    AS id
    , CAST(code AS string)                AS code
    , CAST(name AS string)                AS name
    , CAST(issued_date AS date)           AS issued_date
    , CAST(status AS string)              AS status
    , CAST(note AS string)                AS note
    , CAST(created_at AS date)            AS created_at
    , CAST(created_by AS string)          AS created_by
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(last_modified_by AS string)    AS last_modified_by
    , CAST(version AS bigint)             AS version
    , CAST(deleted AS int)                AS deleted
    , CAST(ecatalog_id AS string) AS ecatalog_id
FROM {{ source('source_thanhtra', 'raw_legal_document') }}