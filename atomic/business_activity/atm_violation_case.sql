/*
*--------------------------------------------------------------------*
* Program code: atm_violation_case
* Program name: Atomic Violation Case
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH vi_ca AS (
    SELECT
        code
        , name
        , inspection_team_id
        , examination_team_id
        , source_category
        , source_unit_name
        , assigned_officer_id
        , assigned_officer_name
        , supervising_leader_id
        , supervising_leader_name
        , status
        , market_type
        , bond_issuer_code
        , bond_code
        , processing_progress
        , note
    FROM {{ ref('ods_thanhtra_violation_case') }}
),

it AS (SELECT
    id
    , code
FROM {{ ref('ods_thanhtra_inspection_team') }}
),

ex_te AS (
    SELECT
        id
        ,code
    FROM {{ ref('ods_thanhtra_examination_team') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_VIOLATION_CASE', "vi_ca.code") }}                  AS violation_case_id
    , CAST(vi_ca.code AS string)                                                                  AS violation_case_code
    , CAST('THANHTRA_VIOLATION_CASE' AS string)                                                   AS src_stm_code
    , CAST(vi_ca.name AS string)                                                                  AS violation_case_nm
    , {{ generate_surrogate_key_bigint('THANHTRA_INSPECTION_TEAM', "it.code") }}  AS inspection_team_id
    , CAST(it.code AS string)                                                    AS inspection_team_code
    , {{ generate_surrogate_key_bigint('THANHTRA_EXAMINATION_TEAM', "ex_te.code") }} AS examination_team_id
    , CAST(ex_te.code AS string)                                                   AS examination_team_code
    , CAST(vi_ca.source_category AS string)                                                       AS src_category_code
    , CAST(vi_ca.source_unit_name AS string)                                                      AS src_unit_nm
    , {{ generate_surrogate_key_bigint('NHNCK_USERS', "vi_ca.assigned_officer_id") }}             AS assigned_officer_id
    , CAST(vi_ca.assigned_officer_name AS string)                                                 AS assigned_officer_nm
    , {{ generate_surrogate_key_bigint('NHNCK_USERS', "vi_ca.supervising_leader_id") }}           AS supervising_leader_id
    , CAST(vi_ca.supervising_leader_name AS string)                                               AS supervising_leader_nm
    , CAST(vi_ca.status AS string)                                                                AS life_cycle_status_code
    , CAST(vi_ca.market_type AS string)                                                           AS market_tp_code
    , CAST(vi_ca.bond_issuer_code AS string)                                                      AS bond_issuer_code
    , CAST(vi_ca.bond_code AS string)                                                             AS bond_code
    , CAST(vi_ca.processing_progress AS string)                                                   AS processing_progress
    , CAST(vi_ca.note AS string)                                                                  AS note
FROM vi_ca
left join it on vi_ca.inspection_team_id = it.id
left join ex_te on vi_ca.examination_team_id = ex_te.id