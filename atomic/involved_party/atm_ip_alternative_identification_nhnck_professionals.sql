/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification NHNCK.PROFESSIONALS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pro AS (
    SELECT
        id
        , identity_type
        , identity_number
        , identity_issue_date
        , identity_issue_place
    FROM {{ ref('ods_nhnck_professionals') }}
)

SELECT
    CAST('NHNCK_PROFESSIONALS' AS string)                                  AS src_stm_code
    , coalesce(CAST(pro.identity_type AS string), 'NULL')                  AS identification_tp_code
    , CAST(pro.identity_number AS string)                                  AS identification_nbr
    , CAST(pro.identity_issue_date AS date)                                AS identification_issue_dt
    , CAST(pro.identity_issue_place AS string)                             AS identification_issue_place
    , {{ generate_surrogate_key_bigint('NHNCK_PROFESSIONALS', "pro.id") }} AS ip_id
    , CAST(pro.id AS string)                                               AS ip_code
FROM pro