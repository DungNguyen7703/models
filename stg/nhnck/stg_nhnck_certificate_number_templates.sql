/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_certificate_number_templates
* Program name: Staging NHNCK.CERTIFICATE_NUMBER_TEMPLATES
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
    , CAST(code AS string)        AS code
    , CAST(certificate_id AS int) AS certificate_id
    , CAST(type AS int)           AS type
    , CAST(is_default AS int)     AS is_default
    , CAST(name AS string)        AS name
    , CAST(created_at AS date)    AS created_at
    , CAST(updated_at AS date)    AS updated_at
    , CAST(created_by AS int)     AS created_by
    , CAST(updated_by AS int)     AS updated_by
FROM {{ source('source_nhnck', 'raw_certificate_number_templates') }}