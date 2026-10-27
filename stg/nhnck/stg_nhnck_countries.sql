/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_countries
* Program name: Staging NHNCK.COUNTRIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                AS id
    , CAST(country_code AS string) AS country_code
    , CAST(country_name AS string) AS country_name
    , CAST(is_default AS int)      AS is_default
    , CAST(created_at AS date)     AS created_at
    , CAST(created_by AS int)      AS created_by
    , CAST(updated_at AS date)     AS updated_at
    , CAST(status AS int)          AS status
    , CAST(updated_by AS int)      AS updated_by
    , CAST(ecatalog_id AS string)  AS ecatalog_id
FROM {{ source('source_nhnck', 'raw_countries') }}