/*
*--------------------------------------------------------------------*
* Program code: atm_pc_entity_role
* Program name: Atomic Public Company Entity Role
* Created by: tuan.nguyenvanb
* Created date: 2026-10-01
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-01		tuan.nguyenvanb		[MOI, theo atomic LLD lld_IDS_COMPANY_ENTITY_ROLE.yaml]
*                                       Vai tro cua phap nhan doi voi cong ty dai chung
*                                       (role_tp_code: 'NNB' = Nguoi noi bo, ...). Phuc vu
*                                       dtm_opr_public_company_insider_ownership (GSTT Nhom 35).
*                                       Chi giu ban ghi chua xoa (delete_flg = 0) - cung cach voi
*                                       atm_legal_entity_position; LLD atomic chua co cot co xoa
*                                       (O_GSTT_55) - ban ghi bi xoa o nguon se chuyen INACTIVE
*                                       theo co che scd4a.
*--------------------------------------------------------------------*
*/

WITH en_ro AS (
    SELECT
        id
        , company_profile_id
        , legal_entity_id
        , role_type_cd
        , effective_from_date
        , effective_to_date
    FROM {{ ref('ods_ids_company_entity_role') }}
    WHERE delete_flg = 0
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_COMPANY_ENTITY_ROLE', "en_ro.id") }}                      AS pc_entity_role_id
    , CAST(en_ro.id AS string)                                                                      AS pc_entity_role_code
    , CAST('IDS_COMPANY_ENTITY_ROLE' AS string)                                                     AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "en_ro.company_profile_id") }}       AS pc_id
    , CAST(en_ro.company_profile_id AS string)                                                      AS pc_code
    , {{ generate_surrogate_key_bigint('IDS_LEGAL_ENTITIES', "en_ro.legal_entity_id") }}            AS legal_entity_id
    , CAST(en_ro.legal_entity_id AS string)                                                         AS legal_entity_code
    , CAST(en_ro.role_type_cd AS string)                                                            AS role_tp_code
    , CAST(en_ro.effective_from_date AS date)                                                       AS effective_from_dt
    , CAST(en_ro.effective_to_date AS date)                                                         AS effective_to_dt
FROM en_ro
