/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification FMS.BANK_MONI
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-07		tuan.nguyenvanb		[FIX] Doi thu tu cot SELECT cho khop cac child khac
*                                       (src_stm_code, identification_tp_code, identification_nbr,
*                                       identification_issue_dt, identification_issue_place, ip_id,
*                                       ip_code). UNION ALL cua parent ghep cot theo VI TRI; thu tu cu
*                                       (ip_id, ip_code dau tien) lam cot thu 4 la chuoi nen
*                                       identification_issue_dt bi ep sang STRING, ghi vao _hstr
*                                       (kieu DATE) bao loi CANNOT_SAFELY_CAST.
*--------------------------------------------------------------------*
*/

WITH ba_mo AS (
    SELECT
        id
        , cert_no
    FROM {{ ref('ods_fms_bank_moni') }}
)

SELECT
    CAST('FMS_BANK_MONI' AS string)                                  AS src_stm_code
    , CAST('ELIGIBILITY_CERTIFICATE' AS string)                      AS identification_tp_code
    , CAST(ba_mo.cert_no AS string)                                  AS identification_nbr
    , CAST(NULL AS date)                                             AS identification_issue_dt
    , CAST(NULL AS string)                                           AS identification_issue_place
    , {{ generate_surrogate_key_bigint('FMS_BANK_MONI', "ba_mo.id") }} AS ip_id
    , CAST(ba_mo.id AS string)                                       AS ip_code
FROM ba_mo