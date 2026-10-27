/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_certificate_specializations
* Program name: Staging NHNCK.CERTIFICATE_SPECIALIZATIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                  AS id
    , CAST(certificate_id AS int)    AS certificate_id
    , CAST(specialization_id AS int) AS specialization_id
    , CAST(sort_order AS int)        AS sort_order
    , CAST(document_type AS int)     AS document_type
    , CAST(is_required AS int)       AS is_required
FROM {{ source('source_nhnck', 'raw_certificate_specializations') }}