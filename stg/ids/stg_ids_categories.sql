/*
*--------------------------------------------------------------------*
* Program code: stg_ids_categories
* Program name: Staging IDS.CATEGORIES
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
    , CAST(industry_cd AS string)   AS industry_cd
    , CAST(industry_name AS string) AS industry_name
    , CAST(description AS string)   AS description
    , CAST(parent_id AS int)        AS parent_id
    , CAST(active_flg AS int)       AS active_flg
    , CAST(created_by AS string)    AS created_by
    , CAST(created_date AS date)    AS created_date
    , CAST(updated_by AS string)    AS updated_by
    , CAST(updated_date AS date)    AS updated_date
    , CAST(status_flg AS int)       AS status_flg
    , CAST(id_sync AS string)       AS id_sync
FROM {{ source('source_ids', 'raw_categories') }}