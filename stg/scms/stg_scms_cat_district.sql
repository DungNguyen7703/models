/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_district
* Program name: Staging SCMS.CAT_DISTRICT
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
    , CAST(province_id AS int)      AS province_id
    , CAST(district_code AS string) AS district_code
    , CAST(district_name AS string) AS district_name
    , CAST(note AS string)          AS note
    , CAST(created_by AS int)       AS created_by
    , CAST(created_at AS timestamp) AS created_at
    , CAST(record_status AS int)    AS record_status
FROM {{ source('source_scms', 'raw_cat_district') }}
