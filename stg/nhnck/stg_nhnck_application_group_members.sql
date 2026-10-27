/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_group_members
* Program name: Staging NHNCK.APPLICATION_GROUP_MEMBERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                     AS id
    , CAST(application_group_id AS int) AS application_group_id
    , CAST(application_id AS int)       AS application_id
    , CAST(status AS int)               AS status
    , CAST(notes AS string)             AS notes
    , CAST(order_index AS int)          AS order_index
FROM {{ source('source_nhnck', 'raw_application_group_members') }}