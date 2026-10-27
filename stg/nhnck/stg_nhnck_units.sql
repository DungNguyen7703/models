/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_units
* Program name: Staging NHNCK.UNITS
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
    , CAST(parent_id AS int)       AS parent_id
    , CAST(level_ AS string)       AS level_
    , CAST(unit_code AS string)    AS unit_code
    , CAST(unit_name AS string)    AS unit_name
    , CAST(address AS string)      AS address
    , CAST(phone_number AS string) AS phone_number
    , CAST(email AS string)        AS email
    , CAST(fax AS string)          AS fax
    , CAST(description AS string)  AS description
    , CAST(created_at AS date)     AS created_at
    , CAST(created_by AS int)      AS created_by
    , CAST(updated_at AS date)     AS updated_at
    , CAST(status AS int)          AS status
    , CAST(updated_by AS int)      AS updated_by
FROM {{ source('source_nhnck', 'raw_units') }}