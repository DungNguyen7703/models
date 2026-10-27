/*
*--------------------------------------------------------------------*
* Program code: atm_legal_entity_position
* Program name: Atomic Legal Entity Position IDS.POSITIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-16		tuan.nguyenvanb		[FIX] Cot atomic phai phan anh dung du lieu
*                                       nguon - 1 legal_entity co the co nhieu
*                                       position (giu du, KHONG dedupe o day - viec
*                                       chon "chuc vu moi nhat" la logic nghiep vu
*                                       cua tang mart opr_public_company_shareholding,
*                                       khong phai cua atomic). Chi sua loi cu phap
*                                       thieu WHERE truoc delete_flg.
*--------------------------------------------------------------------*
*/

WITH posi AS (
    SELECT
        id
        , legal_entity_id
        , position_cd
        , appointment_date
        , dismissal_date
        , active_flg
        , delete_flg
        , company_profile_id
    FROM {{ ref('ods_ids_positions') }}
    WHERE delete_flg = 0
)

SELECT
    {{ generate_surrogate_key_bigint('IDS_POSITIONS', "posi.id") }}                     AS legal_entity_position_id
    , CAST(posi.id AS string)                                                           AS legal_entity_position_code
    , CAST('IDS_POSITIONS' AS string)                                                   AS src_stm_code
    , {{ generate_surrogate_key_bigint('IDS_LEGAL_ENTITIES', "posi.legal_entity_id") }} AS legal_entity_id
    , CAST(posi.legal_entity_id AS string)                                              AS legal_entity_code
    , CAST(posi.position_cd AS string)                                                  AS position_code
    , CAST(posi.appointment_date AS date)                                               AS appointment_dt
    , CAST(posi.dismissal_date AS date)                                                 AS dismissal_dt
    , CAST(posi.active_flg AS int)                                                      AS active_indicator
    , CAST(posi.delete_flg AS int)                                                      AS deleted_indicator
    ,{{ generate_surrogate_key_bigint('IDS_COMPANY_PROFILES', "posi.company_profile_id") }}                     AS pc_id
FROM posi