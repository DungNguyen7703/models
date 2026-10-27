/*
*--------------------------------------------------------------------*
* Program code: atm_ip_alternative_identification
* Program name: Atomic Involved Party Alternative Identification IDS.IDENTITY
* Created by: tuan.nguyenvanb
* Created date: 2026-09-25
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-25		tuan.nguyenvanb		[MOI, dong gap phat hien qua build fct_major_
*                                       shareholder_ownership_snpst] atm_ip_alternative_
*                                       identification truoc day KHONG CO nhanh nguon nao
*                                       ten IDS_IDENTITY (chi co FIMS/FMS/NHNCK/SCMS) -
*                                       khien cot position_code cua fct_major_shareholder_
*                                       ownership_snpst luon rong. Them nhanh nay tu
*                                       ods_ids_identity (co san, chi chua duoc boc thanh
*                                       atomic) - ip_id sinh surrogate key CUNG CACH voi
*                                       atm_legal_entity_position.legal_entity_id
*                                       (generate_surrogate_key_bigint('IDS_LEGAL_ENTITIES',
*                                       legal_entity_id)) de 2 ben khop dung khi JOIN.
*--------------------------------------------------------------------*
*/

WITH iden AS (
    SELECT
        id
        , legal_entity_id
        , identity_type_cd
        , identity_no
        , identity_issued_date
        , identity_issued_place
        , delete_flg
    FROM {{ ref('ods_ids_identity') }}
    WHERE delete_flg = 0
)

SELECT
    CAST('IDS_IDENTITY' AS string)                                                  AS src_stm_code
    , CAST(iden.identity_type_cd AS string)                                         AS identification_tp_code
    , CAST(iden.identity_no AS string)                                              AS identification_nbr
    , CAST(iden.identity_issued_date AS date)                                       AS identification_issue_dt
    , CAST(iden.identity_issued_place AS string)                                    AS identification_issue_place
    , {{ generate_surrogate_key_bigint('IDS_LEGAL_ENTITIES', "iden.legal_entity_id") }} AS ip_id
    , CAST(iden.legal_entity_id AS string)                                          AS ip_code
FROM iden
