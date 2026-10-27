/*
*--------------------------------------------------------------------*
* Program code: atm_pd_subject
* Program name: Atomic Penalty Decision Subject
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pe_de_su AS (
    SELECT
        id
        , penalty_decision_id
        , subject_type
        , subject_name
        , subject_id_number
        , subject_address
        , subject_tax_code
        , subject_dob
        , subject_legal_rep
        , subject_legal_rep_title
        , total_fine_amount
        , paid_amount
        , coerced_amount
        , payment_received_date
        , compliance_status
        , enforcement_progress
        , note
        , payment_proof_url
        , payment_proof_uploaded_at
    FROM {{ ref('ods_thanhtra_penalty_decision_subject') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_PENALTY_DECISION_SUBJECT', "pe_de_su.id") }}            AS pd_subject_id
    , CAST(pe_de_su.id AS string)                                                                      AS pd_subject_code
    , CAST('THANHTRA_PENALTY_DECISION_SUBJECT' AS string)                                              AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_PENALTY_DECISION', "pe_de_su.penalty_decision_id") }} AS pd_id
    , CAST(pe_de_su.penalty_decision_id AS string)                                                     AS pd_code
    , CAST(pe_de_su.subject_type AS string)                                                            AS subject_tp_code
    , CAST(pe_de_su.subject_name AS string)                                                            AS subject_nm
    , CAST(pe_de_su.subject_id_number AS string)                                                       AS subject_id_nbr
    , CAST(pe_de_su.subject_address AS string)                                                         AS subject_adr
    , CAST(pe_de_su.subject_tax_code AS string)                                                        AS subject_tax_code
    , CAST(pe_de_su.subject_dob AS date)                                                               AS subject_dt_of_birth
    , CAST(pe_de_su.subject_legal_rep AS string)                                                       AS subject_legal_rep
    , CAST(pe_de_su.subject_legal_rep_title AS string)                                                 AS subject_legal_rep_title
    , CAST(pe_de_su.total_fine_amount AS decimal(23,2))                                                AS total_fine_amt
    , CAST(pe_de_su.paid_amount AS decimal(23,2))                                                      AS paid_amt
    , CAST(pe_de_su.coerced_amount AS decimal(23,2))                                                   AS coerced_amt
    , CAST(pe_de_su.payment_received_date AS date)                                                     AS payment_received_dt
    , CAST(pe_de_su.compliance_status AS string)                                                       AS compliance_status_code
    , CAST(pe_de_su.enforcement_progress AS string)                                                    AS enforcement_progress
    , CAST(pe_de_su.note AS string)                                                                    AS note
    , CAST(pe_de_su.payment_proof_url AS string)                                                       AS payment_proof_url
    , CAST(pe_de_su.payment_proof_uploaded_at AS timestamp)                                            AS payment_proof_uploaded_tms
FROM pe_de_su