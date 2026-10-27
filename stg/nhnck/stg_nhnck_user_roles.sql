/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_user_roles
* Program name: Staging NHNCK.USER_ROLES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)        AS id
    , CAST(user_id AS int) AS user_id
    , CAST(role_id AS int) AS role_id
FROM {{ source('source_nhnck', 'raw_user_roles') }}