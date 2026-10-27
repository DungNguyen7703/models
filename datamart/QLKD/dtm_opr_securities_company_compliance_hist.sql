/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_securities_company_compliance_hist
* Program name: Dtm Opr Securities Company Compliance Hist
* Created by: tuan.nguyenvanb
* Created date: 2026-10-02
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-02		tuan.nguyenvanb		[SUA, review Nhom 40] Doi driving
*                                       table nhanh EXAMINATION/INSPECTION
*                                       tu pd_subject_behavior (INNER) sang
*                                       examination_team_target JOIN
*                                       examination_team / inspection_team_
*                                       target JOIN inspection_team.
* 2026-10-19		claude				[SUA theo LLD moi nhat, BA STT 40 cap
*                                       nhat 19/10] Viet lai toan bo 4 nhanh
*                                       UNION theo dung 4 file LLD:
*                                       - EXAMINATION/INSPECTION: doi grain ve
*                                         1 dong/dot kiem tra/thanh tra (bo
*                                         fan-out theo hanh vi, bo CONCAT
*                                         NOVIOLATION). Them filter
*                                         decision_nbr IS NOT NULL. NULL hoa
*                                         issued_dt/violation_behavior_nm/
*                                         supplementary_penalty_nm/remedial_
*                                         measure_nm (khong ap dung nhanh
*                                         nay). event_dt = decision_dt truc
*                                         tiep (bo COALESCE voi issued_dt).
*                                         sc_code resolve qua business_
*                                         registration_nbr/subject_tax_code
*                                         noi qua ip_alternative_identification
*                                         (identification_tp_code='TAX_ID'),
*                                         KHONG dung securities_company.tax_code
*                                         (cot khong ton tai trong atomic).
*                                       - PENALTY_DECISION (moi): driven theo
*                                         pd_subject (1 dong/doi tuong), noi
*                                         ip_alternative_identification qua
*                                         subject_id_nbr.
*                                       - PENALTY_DETAIL (moi): driven theo
*                                         pd_subject LEFT JOIN pd_subject_
*                                         behavior (1 dong/doi tuong x hanh
*                                         vi), noi qua subject_tax_code.
*                                       - Bo nhanh ADMIN_PENALTY_DECISION
*                                         (khong co trong 4 file LLD hien
*                                         hanh).
* 2026-10-19		claude				[CAP NHAT] atm_examination_team va
*                                       atm_penalty_decision da duoc bo sung
*                                       vao models/atomic (business_activity/
*                                       atm_examination_team.sql, event/
*                                       atm_penalty_decision.sql,
*                                       materialized: scd4a). Da doi chieu:
*                                       ca 2 output dung du cot ma model nay
*                                       dang dung (examination_team_id/
*                                       form_tp_code/decision_dt/decision_nbr/
*                                       src_stm_code va pd_id/decision_nbr/
*                                       issued_dt/src_stm_code) - khong can
*                                       sua logic SQL, model nay da dbt run
*                                       duoc.
* GAP THIET KE DANG MO (audit 2026-09-19, giu nguyen theo quyet dinh
* nghiep vu - CHUA duoc tu y sua): nhanh INSPECTION van JOIN
* in_te_ta ON in_te_ta.target_nm = pe_de_su.subject_nm - text-match theo
* TEN (khac EXAMINATION co them business_registration_nbr). Can BA/team
* THANHTRA xac nhan chat luong du lieu truoc khi doi sang join dinh danh
* giong EXAMINATION.
*--------------------------------------------------------------------*
*/

WITH pe_de_su AS (
    SELECT
        pd_subject_id,
        pd_subject_code,
        pd_id,
        subject_tp_code,
        subject_nm,
        subject_id_nbr,
        subject_tax_code,
        src_stm_code
    FROM {{ ref('atm_pd_subject') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION_SUBJECT'
),

pd_su_be AS (
    SELECT
        pd_subject_behavior_code,
        pd_subject_id,
        violation_behavior_id,
        penalty_tp_id,
        src_stm_code
    FROM {{ ref('atm_pd_subject_behavior') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION_SUBJECT_BEHAVIOR'
),

pe_de AS (
    SELECT
        pd_id,
        decision_nbr,
        issued_dt,
        src_stm_code
    FROM {{ ref('atm_penalty_decision') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION'
),

ex_te_ta AS (
    SELECT
        examination_team_target_code,
        target_tp_code,
        target_reference_id,
        target_nm,
        business_registration_nbr,
        examination_team_id,
        src_stm_code
    FROM {{ ref('atm_examination_team_target') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_EXAMINATION_TEAM_TARGET'
),

ex_te AS (
    SELECT
        examination_team_id,
        form_tp_code,
        decision_dt,
        decision_nbr,
        src_stm_code
    FROM {{ ref('atm_examination_team') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_EXAMINATION_TEAM'
),

in_te_ta AS (
    SELECT
        inspection_team_target_code,
        target_nm,
        target_tp_code,
        target_reference_id,
        inspection_team_id,
        src_stm_code
    FROM {{ ref('atm_inspection_team_target') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_INSPECTION_TEAM_TARGET'
),

in_te AS (
    SELECT
        inspection_team_id,
        form_tp_code,
        decision_dt,
        decision_nbr,
        src_stm_code
    FROM {{ ref('atm_inspection_team') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_INSPECTION_TEAM'
),

vi_be AS (
    SELECT
        violation_behavior_id,
        violation_behavior_nm,
        src_stm_code
    FROM {{ ref('atm_violation_behavior') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_VIOLATION_BEHAVIOR'
),

pe_ty AS (
    SELECT
        penalty_tp_id,
        penalty_tp_nm,
        penalty_category_code,
        life_cycle_status_code,
        src_stm_code
    FROM {{ ref('atm_penalty_type') }}
    WHERE src_stm_code = 'THANHTRA_PENALTY_TYPE'
        AND life_cycle_status_code = 'ACTIVE'
),

ip_al_id_tax AS (
    SELECT
        ip_id,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
        AND identification_tp_code = 'TAX_ID'
),

se_co AS (
    SELECT
        sc_id,
        sc_code
    FROM {{ ref('atm_securities_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
)

-- Nhanh EXAMINATION: grain 1 dong / dot kiem tra x 1 doi tuong CTCK
SELECT
    CAST(ex_te_ta.examination_team_target_code AS string)     AS compliance_event_code,
    CAST(se_co.sc_code AS string)                              AS sc_code,
    CAST('EXAMINATION' AS string)                              AS event_tp_code,
    CAST(ex_te.decision_nbr AS string)                         AS decision_nbr,
    NULL                                                       AS issued_dt,
    CAST(ex_te.form_tp_code AS string)                         AS form_tp_code,
    CAST(ex_te.decision_dt AS date)                            AS insp_decision_dt,
    NULL                                                       AS violation_behavior_nm,
    NULL                                                       AS supplementary_penalty_nm,
    NULL                                                       AS remedial_measure_nm,
    CAST(ex_te_ta.src_stm_code AS string)                      AS src_stm_code,
    CAST(ex_te.decision_dt AS date)                            AS event_dt
FROM ex_te_ta
JOIN ex_te
    ON  ex_te.examination_team_id = ex_te_ta.examination_team_id
LEFT JOIN ip_al_id_tax
    ON  ip_al_id_tax.identification_nbr = COALESCE(
            ex_te_ta.business_registration_nbr,
            (SELECT MAX(subject_tax_code) FROM pe_de_su WHERE pe_de_su.subject_nm = ex_te_ta.target_nm AND pe_de_su.subject_tp_code = 'ORGANIZATION')
        )
LEFT JOIN se_co
    ON  se_co.sc_id = ip_al_id_tax.ip_id
WHERE ex_te_ta.target_tp_code = 'SECURITIES_COMPANY'
    AND ex_te.decision_nbr IS NOT NULL

UNION ALL

-- Nhanh INSPECTION: grain 1 dong / dot thanh tra x 1 doi tuong CTCK
SELECT
    CAST(in_te_ta.inspection_team_target_code AS string)      AS compliance_event_code,
    CAST(se_co.sc_code AS string)                              AS sc_code,
    CAST('INSPECTION' AS string)                               AS event_tp_code,
    CAST(in_te.decision_nbr AS string)                         AS decision_nbr,
    NULL                                                       AS issued_dt,
    CAST(in_te.form_tp_code AS string)                         AS form_tp_code,
    CAST(in_te.decision_dt AS date)                            AS insp_decision_dt,
    NULL                                                       AS violation_behavior_nm,
    NULL                                                       AS supplementary_penalty_nm,
    NULL                                                       AS remedial_measure_nm,
    CAST(in_te_ta.src_stm_code AS string)                      AS src_stm_code,
    CAST(in_te.decision_dt AS date)                            AS event_dt
FROM in_te_ta
JOIN in_te
    ON  in_te.inspection_team_id = in_te_ta.inspection_team_id
LEFT JOIN ip_al_id_tax
    ON  ip_al_id_tax.identification_nbr = (SELECT MAX(subject_tax_code) FROM pe_de_su WHERE pe_de_su.subject_nm = in_te_ta.target_nm AND pe_de_su.subject_tp_code = 'ORGANIZATION')
LEFT JOIN se_co
    ON  se_co.sc_id = ip_al_id_tax.ip_id
WHERE in_te_ta.target_tp_code = 'SECURITIES_COMPANY'
    AND in_te.decision_nbr IS NOT NULL

UNION ALL

-- Nhanh PENALTY_DECISION: grain 1 dong / 1 doi tuong bi xu phat
SELECT
    CAST(pe_de_su.pd_subject_code AS string)                   AS compliance_event_code,
    CAST(se_co.sc_code AS string)                              AS sc_code,
    CAST('PENALTY_DECISION' AS string)                         AS event_tp_code,
    CAST(pe_de.decision_nbr AS string)                         AS decision_nbr,
    CAST(pe_de.issued_dt AS date)                              AS issued_dt,
    NULL                                                       AS form_tp_code,
    NULL                                                       AS insp_decision_dt,
    NULL                                                       AS violation_behavior_nm,
    NULL                                                       AS supplementary_penalty_nm,
    NULL                                                       AS remedial_measure_nm,
    CAST(pe_de_su.src_stm_code AS string)                      AS src_stm_code,
    CAST(pe_de.issued_dt AS date)                              AS event_dt
FROM pe_de_su
JOIN pe_de
    ON  pe_de.pd_id = pe_de_su.pd_id
LEFT JOIN ip_al_id_tax
    ON  ip_al_id_tax.identification_nbr = pe_de_su.subject_id_nbr
LEFT JOIN se_co
    ON  se_co.sc_id = ip_al_id_tax.ip_id
WHERE pe_de.issued_dt IS NOT NULL

UNION ALL

-- Nhanh PENALTY_DETAIL: grain 1 dong / 1 doi tuong x 1 hanh vi
SELECT
    CAST(CONCAT(pe_de_su.pd_subject_code, '_', COALESCE(pd_su_be.pd_subject_behavior_code, 'NOBEHAVIOR')) AS string) AS compliance_event_code,
    CAST(se_co.sc_code AS string)                              AS sc_code,
    CAST('PENALTY_DETAIL' AS string)                           AS event_tp_code,
    CAST(pe_de.decision_nbr AS string)                         AS decision_nbr,
    CAST(pe_de.issued_dt AS date)                              AS issued_dt,
    NULL                                                       AS form_tp_code,
    NULL                                                       AS insp_decision_dt,
    CAST(vi_be.violation_behavior_nm AS string)                AS violation_behavior_nm,
    CAST(pe_ty_sup.penalty_tp_nm AS string)                    AS supplementary_penalty_nm,
    CAST(pe_ty_rem.penalty_tp_nm AS string)                    AS remedial_measure_nm,
    CAST(pe_de_su.src_stm_code AS string)                      AS src_stm_code,
    CAST(pe_de.issued_dt AS date)                              AS event_dt
FROM pe_de_su
JOIN pe_de
    ON  pe_de.pd_id = pe_de_su.pd_id
LEFT JOIN pd_su_be
    ON  pd_su_be.pd_subject_id = pe_de_su.pd_subject_id
LEFT JOIN vi_be
    ON  vi_be.violation_behavior_id = pd_su_be.violation_behavior_id
LEFT JOIN pe_ty pe_ty_sup
    ON  pe_ty_sup.penalty_tp_id = pd_su_be.penalty_tp_id
    AND pe_ty_sup.penalty_category_code = 'SUPPLEMENTARY_PENALTY'
LEFT JOIN pe_ty pe_ty_rem
    ON  pe_ty_rem.penalty_tp_id = pd_su_be.penalty_tp_id
    AND pe_ty_rem.penalty_category_code = 'REMEDIAL_MEASURE'
LEFT JOIN ip_al_id_tax
    ON  ip_al_id_tax.identification_nbr = pe_de_su.subject_tax_code
LEFT JOIN se_co
    ON  se_co.sc_id = ip_al_id_tax.ip_id
WHERE pe_de.issued_dt IS NOT NULL
