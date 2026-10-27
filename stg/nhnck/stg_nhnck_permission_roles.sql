/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_permission_roles
* Program name: Staging NHNCK.PERMISSION_ROLES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)              AS id
    , CAST(permission_id AS int) AS permission_id
    , CAST(role_id AS int)       AS role_id
FROM {{ source('source_nhnck', 'raw_permission_roles') }}