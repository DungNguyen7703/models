/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_forms
* Program name: Staging NHNCK.FORMS
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
    , CAST(certificate_id AS int) AS certificate_id
    , CAST(form_name AS string)   AS form_name
    , CAST(reference AS string)   AS reference
    , CAST(description AS string) AS description
    , CAST(file_name AS string)   AS file_name
    , CAST(file_path AS string)   AS file_path
    , CAST(created_at AS date)    AS created_at
    , CAST(created_by AS int)     AS created_by
    , CAST(updated_at AS date)    AS updated_at
    , CAST(status AS int)         AS status
    , CAST(sort_order AS int)     AS sort_order
    , CAST(is_featured AS int)    AS is_featured
    , CAST(updated_by AS int)     AS updated_by
FROM {{ source('source_nhnck', 'raw_forms') }}