/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_sources
* Program name: Staging NHNCK.APPLICATION_SOURCES
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
    , CAST(code AS string)        AS code
    , CAST(name AS string)        AS name
    , CAST(label AS string)       AS label
    , CAST(status AS int)         AS status
    , CAST(description AS string) AS description
    , CAST(created_by AS int)     AS created_by
    , CAST(updated_by AS int)     AS updated_by
    , CAST(created_at AS date)    AS created_at
    , CAST(updated_at AS date)    AS updated_at
FROM {{ source('source_nhnck', 'raw_application_sources') }}