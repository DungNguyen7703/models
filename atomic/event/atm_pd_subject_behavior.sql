/*
*--------------------------------------------------------------------*
* Program code: atm_pd_subject_behavior
* Program name: Atomic Penalty Decision Subject Behavior
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pe_de_su_be AS (
    SELECT
        id
        , penalty_decision_subject_id
        , violation_behavior_id
        , penalty_type_id
        , description
        , min_fine_amount
        , max_fine_amount
        , applied_fine_amount
        , remedial_measure
        , remedial_deadline
        , legal_basis
    FROM {{ ref('ods_thanhtra_penalty_decision_subject_behavior') }}
),

vi_be AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_violation_behavior') }}
),

pt AS (
    SELECT
        id
        , code
     FROM {{ ref('ods_thanhtra_penalty_type') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_PENALTY_DECISION_SUBJECT_BEHAVIOR', "pe_de_su_be.id") }}                   AS pd_subject_behavior_id
    , CAST(pe_de_su_be.id AS string)                                                                                      AS pd_subject_behavior_code
    , CAST('THANHTRA_PENALTY_DECISION_SUBJECT_BEHAVIOR' AS string)                                                        AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_PENALTY_DECISION_SUBJECT', "pe_de_su_be.penalty_decision_subject_id") }} AS pd_subject_id
    , CAST(pe_de_su_be.penalty_decision_subject_id AS string)                                                             AS pd_subject_code
    , {{ generate_surrogate_key_bigint('THANHTRA_VIOLATION_BEHAVIOR', "vi_be.code") }}                                     AS violation_behavior_id
    , CAST(vi_be.code AS string)                                                                                          AS violation_behavior_code
    , {{ generate_surrogate_key_bigint('THANHTRA_PENALTY_TYPE', "pt.code") }}                         AS penalty_tp_id
    , CAST(pe_de_su_be.penalty_type_id AS string)                                                                         AS penalty_tp_code
    , CAST(pe_de_su_be.description AS string)                                                                             AS description
    , CAST(pe_de_su_be.min_fine_amount AS decimal(23,2))                                                                  AS min_fine_amt
    , CAST(pe_de_su_be.max_fine_amount AS decimal(23,2))                                                                  AS max_fine_amt
    , CAST(pe_de_su_be.applied_fine_amount AS decimal(23,2))                                                              AS applied_fine_amt
    , CAST(pe_de_su_be.remedial_measure AS string)                                                                        AS remedial_measure
    , CAST(pe_de_su_be.remedial_deadline AS date)                                                                         AS remedial_deadline
    , CAST(pe_de_su_be.legal_basis AS string)                                                                             AS legal_basis
FROM pe_de_su_be
LEFT JOIN vi_be
    ON vi_be.id = pe_de_su_be.violation_behavior_id
LEFT JOIN pt
    ON pt.id = pe_de_su_be.penalty_type_id