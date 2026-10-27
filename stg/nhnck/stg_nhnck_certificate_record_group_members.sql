/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_certificate_record_group_members
* Program name: Staging NHNCK.CERTIFICATE_RECORD_GROUP_MEMBERS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                            AS id
    , CAST(certificate_record_group_id AS int) AS certificate_record_group_id
    , CAST(certificate_record_id AS int)       AS certificate_record_id
    , CAST(added_date AS date)                 AS added_date
    , CAST(added_by AS int)                    AS added_by
    , CAST(status AS int)                      AS status
    , CAST(is_reissue AS int)                  AS is_reissue
    , CAST(revocation_reason AS string)        AS revocation_reason
    , CAST(order_index AS int)                 AS order_index
FROM {{ source('source_nhnck', 'raw_certificate_record_group_members') }}