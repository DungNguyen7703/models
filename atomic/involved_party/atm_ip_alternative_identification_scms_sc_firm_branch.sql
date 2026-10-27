/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification SCMS.SC_FIRM_BRANCH
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_br AS (
    SELECT
        id
        , license_number
        , license_date
    FROM {{ ref('ods_scms_sc_firm_branch') }}
)

SELECT
    CAST('SCMS_SC_FIRM_BRANCH' AS string)                                       AS src_stm_code
    , CAST('OPERATION_LICENSE' AS string)                                       AS identification_tp_code
    , CAST(sc_fi_br.license_number AS string)                                   AS identification_nbr
    , CAST(sc_fi_br.license_date AS date)                                       AS identification_issue_dt
    , CAST(NULL AS string)                                                      AS identification_issue_place
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_BRANCH', "sc_fi_br.id") }} AS ip_id
    , CAST(sc_fi_br.id AS string)                                               AS ip_code
FROM sc_fi_br