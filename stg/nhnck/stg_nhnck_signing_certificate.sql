/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_signing_certificate
* Program name: Staging NHNCK.SIGNING_CERTIFICATE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                 AS id
    , CAST(serial_hex AS string)    AS serial_hex
    , CAST(subject AS string)       AS subject
    , CAST(issuer AS string)        AS issuer
    , CAST(owner_name AS string)    AS owner_name
    , CAST(user_ref AS string)      AS user_ref
    , CAST(valid_from AS timestamp) AS valid_from
    , CAST(valid_to AS timestamp)   AS valid_to
    , CAST(active AS int)           AS active
    , CAST(created_at AS timestamp) AS created_at
FROM {{ source('source_nhnck', 'raw_signing_certificate') }}
