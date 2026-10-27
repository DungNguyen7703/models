/*
*--------------------------------------------------------------------*
* Program code: atm_penalty_decision
* Program name: Atomic Penalty Decision
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH pe_de AS (
    SELECT
        id
        , violation_case_id
        , decision_number
        , issued_date
        , decision_category
        , status
        , signer_id
        , signer_name
        , assigned_officer_id
        , assigned_officer_name
        , submitted_by_id
        , approver_id
        , anti_money_laundering
        , total_fine_amount
        , payment_deadline
        , submitted_at
        , complaint_exists
        , complaint_content
        , complaint_received_date
        , complaint_status
        , complaint_result
        , lawsuit_exists
        , lawsuit_content
        , signed_document_url
        , summary
    FROM {{ ref('ods_thanhtra_penalty_decision') }}
),

vi_ca AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_violation_case') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_PENALTY_DECISION', "pe_de.id") }}                AS pd_id
    , CAST(pe_de.id AS string)                                                                  AS pd_code
    , CAST('THANHTRA_PENALTY_DECISION' AS string)                                               AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_VIOLATION_CASE', "vi_ca.code") }} AS violation_case_id
    , CAST(pe_de.violation_case_id AS string)                                                   AS violation_case_code
    , CAST(pe_de.decision_number AS string)                                                     AS decision_nbr
    , CAST(pe_de.issued_date AS date)                                                           AS issued_dt
    , CAST(pe_de.decision_category AS string)                                                   AS decision_category_code
    , CAST(pe_de.status AS string)                                                              AS life_cycle_status_code
    , {{ generate_surrogate_key_bigint('NHNCK_USERS', "pe_de.signer_id") }}                     AS signer_officer_id
    , CAST(pe_de.signer_name AS string)                                                         AS signer_officer_code
    , {{ generate_surrogate_key_bigint('NHNCK_USERS', "pe_de.assigned_officer_id") }}           AS assigned_officer_id
    , CAST(pe_de.assigned_officer_name AS string)                                               AS assigned_officer_nm
    , {{ generate_surrogate_key_bigint('NHNCK_USERS', "pe_de.submitted_by_id") }}               AS submitted_by_officer_id
    , CAST(pe_de.submitted_by_id AS string)                                                     AS submitted_by_officer_code
    , {{ generate_surrogate_key_bigint('NHNCK_USERS', "pe_de.approver_id") }}                   AS approver_officer_id
    , CAST(pe_de.approver_id AS string)                                                         AS approver_officer_code
    , CAST(pe_de.anti_money_laundering AS string)                                               AS anti_money_laundering_indicator
    , CAST(pe_de.total_fine_amount AS decimal(23,2))                                            AS total_fine_amt
    , CAST(pe_de.payment_deadline AS date)                                                      AS payment_deadline
    , CAST(pe_de.submitted_at AS timestamp)                                                     AS submitted_tms
    , CAST(pe_de.complaint_exists AS string)                                                    AS complaint_exists_indicator
    , CAST(pe_de.complaint_content AS string)                                                   AS complaint_content
    , CAST(pe_de.complaint_received_date AS date)                                               AS complaint_received_dt
    , CAST(pe_de.complaint_status AS string)                                                    AS complaint_status_code
    , CAST(pe_de.complaint_result AS string)                                                    AS complaint_result
    , CAST(pe_de.lawsuit_exists AS string)                                                      AS lawsuit_exists_indicator
    , CAST(pe_de.lawsuit_content AS string)                                                     AS lawsuit_content
    , CAST(pe_de.signed_document_url AS string)                                                 AS signed_document_url
    , CAST(pe_de.summary AS string)                                                             AS summary
FROM pe_de
left join vi_ca on pe_de.violation_case_id = vi_ca.id