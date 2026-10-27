/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_users
* Program name: Staging NHNCK.USERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                         AS id
    , CAST(unit_id AS int)                  AS unit_id
    , CAST(department_id AS int)            AS department_id
    , CAST(position_id AS int)              AS position_id
    , CAST(username AS string)              AS username
    , CAST(password AS string)              AS password
    , CAST(full_name AS string)             AS full_name
    , CAST(email AS string)                 AS email
    , CAST(phone_number AS string)          AS phone_number
    , CAST(gender AS int)                   AS gender
    , CAST(ldap AS string)                  AS ldap
    , CAST(updated_at AS date)              AS updated_at
    , CAST(created_at AS date)              AS created_at
    , CAST(created_by AS int)               AS created_by
    , CAST(status AS int)                   AS status
    , CAST(type AS int)                     AS type
    , CAST(updated_by AS int)               AS updated_by
    , CAST(updated_password_at AS date)     AS updated_password_at
    , CAST(professional_id AS int)          AS professional_id
    , CAST(identity_number AS string)  AS identity_number
    , CAST(sso_user_id AS string)           AS sso_user_id
FROM {{ source('source_nhnck', 'raw_users') }}