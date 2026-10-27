/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification SCMS.SC_FIRM_RELATED_PERSON
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH sc_fi_re_pe AS (
    SELECT
        id
        , identification_number
    FROM {{ ref('ods_scms_sc_firm_related_person') }}
)

SELECT
    CAST('SCMS_SC_FIRM_RELATED_PERSON' AS string)                                          AS src_stm_code
    , CAST('NATIONAL_ID' AS string)                                                        AS identification_tp_code
    , CAST(sc_fi_re_pe.identification_number AS string)                                    AS identification_nbr
    , CAST(NULL AS date)                                                                   AS identification_issue_dt
    , CAST(NULL AS string)                                                                 AS identification_issue_place
    , {{ generate_surrogate_key_bigint('SCMS_SC_FIRM_RELATED_PERSON', "sc_fi_re_pe.id") }} AS ip_id
    , CAST(sc_fi_re_pe.id AS string)                                                       AS ip_code
FROM sc_fi_re_pe