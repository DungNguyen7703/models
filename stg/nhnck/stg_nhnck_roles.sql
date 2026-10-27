/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_roles
* Program name: Staging NHNCK.ROLES
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
    , CAST(group_code AS string)  AS group_code
    , CAST(group_name AS string)  AS group_name
    , CAST(description AS string) AS description
    , CAST(created_at AS date)    AS created_at
    , CAST(created_by AS int)     AS created_by
    , CAST(updated_at AS date)    AS updated_at
    , CAST(status AS int)         AS status
    , CAST(updated_by AS int)     AS updated_by
FROM {{ source('source_nhnck', 'raw_roles') }}