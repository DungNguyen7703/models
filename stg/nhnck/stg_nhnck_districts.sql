/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_districts
* Program name: Staging NHNCK.DISTRICTS
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
    , CAST(country_id AS int)       AS country_id
    , CAST(province_id AS int)      AS province_id
    , CAST(district_code AS string) AS district_code
    , CAST(district_name AS string) AS district_name
    , CAST(created_at AS date)      AS created_at
    , CAST(created_by AS int)       AS created_by
    , CAST(updated_at AS date)      AS updated_at
    , CAST(status AS int)           AS status
    , CAST(type AS int)             AS type
    , CAST(updated_by AS int)       AS updated_by
    , CAST(ecatalog_id AS string)   AS ecatalog_id
FROM {{ source('source_nhnck', 'raw_districts') }}