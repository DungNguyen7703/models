/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_positions
* Program name: Staging NHNCK.POSITIONS
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
    , CAST(position_name AS string) AS position_name
    , CAST(description AS string)   AS description
    , CAST(created_at AS date)      AS created_at
    , CAST(created_by AS int)       AS created_by
    , CAST(updated_at AS date)      AS updated_at
    , CAST(is_active AS int)        AS is_active
    , CAST(status AS int)           AS status
    , CAST(updated_by AS int)       AS updated_by
    , CAST(ecatalog_id AS string)   AS ecatalog_id
    , CAST(position_code AS string) AS position_code
FROM {{ source('source_nhnck', 'raw_positions') }}