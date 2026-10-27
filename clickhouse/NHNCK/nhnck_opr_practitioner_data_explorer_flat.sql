-- ────────────────────────────────────────────────────────────
-- Model : nhnck_opr_practitioner_data_explorer_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

WITH explorer AS (
    SELECT
        practitioner_code,
        license_certificate_document_code,
        full_nm,
        certificate_nbr,
        certificate_tp_code,
        certificate_tp_nm,
        practice_status_code,
        practice_status_nm,
        issue_dt,
        current_organization_nm,
        identification_tp_code,
        src_stm_code
    FROM {{ ref('dtm_opr_practitioner_data_explorer') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
),

p360_profile AS (
    SELECT
        practitioner_code,
        birth_dt,
        identification_nbr,
        education_level_nm,
        age,
        nationality_nm
    FROM {{ ref('dtm_opr_practitioner_360_profile') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
),

exam_hist AS (
    SELECT
        practitioner_code,
        assessment_nm,
        examination_period,
        examination_start_dt,
        examination_end_dt,
        overall_result_nm
    FROM {{ ref('dtm_opr_practitioner_exam_hist') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
),

violation_hist AS (
    SELECT
        practitioner_code,
        decision_nbr,
        decision_signed_dt,
        note
    FROM {{ ref('dtm_opr_practitioner_violation_hist') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
      AND ds_rcrd_st = 'ACTIVE'
)

SELECT
    o.practitioner_code,
    o.license_certificate_document_code,
    o.full_nm,
    o.certificate_nbr,
    o.certificate_tp_code,
    o.certificate_tp_nm,
    o.practice_status_code,
    o.practice_status_nm,
    o.issue_dt,
    o.current_organization_nm,
    o.identification_tp_code,
    o.src_stm_code,
    p360.birth_dt                      AS birth_dt,
    p360.identification_nbr            AS identification_nbr,
    p360.education_level_nm            AS education_level_nm,
    p360.age                           AS age,
    p360.nationality_nm                AS nationality_nm,
    exam.assessment_nm                 AS exam_assessment_nm,
    exam.examination_period            AS exam_examination_period,
    exam.examination_start_dt          AS exam_examination_start_dt,
    exam.examination_end_dt            AS exam_examination_end_dt,
    exam.overall_result_nm             AS exam_overall_result_nm,
    viol.decision_nbr                  AS violation_decision_nbr,
    viol.decision_signed_dt            AS violation_decision_signed_dt,
    viol.note                          AS violation_note

FROM explorer o
LEFT JOIN p360_profile p360
    ON p360.practitioner_code = o.practitioner_code
LEFT JOIN exam_hist exam
    ON exam.practitioner_code = o.practitioner_code
LEFT JOIN violation_hist viol
    ON viol.practitioner_code = o.practitioner_code