/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification SCMS.SC_FIRM_INSIDER_RELATION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_in_re AS (
    SELECT
        id
        , national_id
    FROM {{ ref('ods_scms_sc_firm_insider_relation') }}
)

SELECT
    CAST('SCMS_SC_FIRM_INSIDER_RELATION' AS string)                                          AS src_stm_code
    , CAST('NATIONAL_ID' AS string)                                                          AS identification_tp_code
    , CAST(sc_fi_in_re.national_id AS string)                                                AS identification_nbr
    , CAST(NULL AS date)                                                                     AS identification_issue_dt
    , CAST(NULL AS string)                                                                   AS identification_issue_place
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_INSIDER_RELATION', "sc_fi_in_re.id") }} AS ip_id
    , CAST(sc_fi_in_re.id AS string)                                                         AS ip_code
FROM sc_fi_in_re