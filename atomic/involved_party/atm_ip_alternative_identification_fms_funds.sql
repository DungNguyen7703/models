/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification FMS.FUNDS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-07		claude				identification_tp_code: TAX_ID -> ESTABLISHMENT_OPERATION_LICENSE theo LLD FUNDS_IP_Alt_Identification
*--------------------------------------------------------------------*
*/

WITH fund AS (
    SELECT
        id
        , id_no
        , id_date
    FROM {{ ref('ods_fms_funds') }}
)

SELECT
    CAST('FMS_FUNDS' AS string)                               AS src_stm_code
    , CAST('ESTABLISHMENT_OPERATION_LICENSE' AS string)                                AS identification_tp_code
    , CAST(fund.id_no AS string)                                AS identification_nbr
    , CAST(fund.id_date AS date)                                AS identification_issue_dt
    , CAST(NULL AS string)                                      AS identification_issue_place
    , {{ generate_surrogate_key_bigint('FMS_FUNDS', "fund.id") }} AS ip_id
    , CAST(fund.id AS string)                                   AS ip_code
FROM fund