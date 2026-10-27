/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_auto_increment_codes
* Program name: Staging NHNCK.AUTO_INCREMENT_CODES
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
    , CAST(code AS string)        AS code
    , CAST(record_type AS int)    AS record_type
    , CAST(document_type AS int)  AS document_type
FROM {{ source('source_nhnck', 'raw_auto_increment_codes') }}