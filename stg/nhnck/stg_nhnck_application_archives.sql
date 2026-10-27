/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_archives
* Program name: Staging NHNCK.APPLICATION_ARCHIVES
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
    , CAST(application_id AS int)  AS application_id
    , CAST(location AS string)     AS location
    , CAST(phone_number AS string) AS phone_number
    , CAST(contact AS string)      AS contact
    , CAST(note AS string)         AS note
    , CAST(created_at AS date)     AS created_at
    , CAST(created_by AS int)      AS created_by
    , CAST(updated_at AS date)     AS updated_at
    , CAST(updated_by AS int)      AS updated_by
FROM {{ source('source_nhnck', 'raw_application_archives') }}