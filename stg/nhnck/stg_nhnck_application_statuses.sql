/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_statuses
* Program name: Staging NHNCK.APPLICATION_STATUSES
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
    , CAST(status_code AS string)   AS status_code
    , CAST(status_name AS string)   AS status_name
    , CAST(label AS string)         AS label
    , CAST(description AS string)   AS description
    , CAST(sort_order AS int)       AS sort_order
    , CAST(is_active AS int)        AS is_active
    , CAST(is_original_data AS int) AS is_original_data
    , CAST(created_by AS int)       AS created_by
    , CAST(updated_by AS int)       AS updated_by
    , CAST(created_at AS date)      AS created_at
    , CAST(updated_at AS date)      AS updated_at
FROM {{ source('source_nhnck', 'raw_application_statuses') }}