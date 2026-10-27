/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_penalty_decision_list
* Program name: Operational Penalty Decision List
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-18   Claude   Fix life_cycle_status_code: doi nguon tu
*                       penalty_decision sang violation_case, bo sung
*                       CASE WHEN map nhan tieng Viet theo LLD
*--------------------------------------------------------------------*
*/

WITH pe_de_su AS (
    SELECT
        pd_subject_code,
        subject_nm,
        subject_tp_code,
        total_fine_amt,
        pd_id,
        src_stm_code
    FROM {{ ref('atm_pd_subject') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION_SUBJECT'
),

pe_de AS (
    SELECT
        pd_id,
        violation_case_id,
        issued_dt
    FROM {{ ref('atm_penalty_decision') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_PENALTY_DECISION'
),

vi_ca AS (
    SELECT
        violation_case_id,
        violation_case_code,
        life_cycle_status_code,
        inspection_team_id,
        examination_team_id
    FROM {{ ref('atm_violation_case') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_VIOLATION_CASE'
),

in_te AS (
    SELECT
        inspection_team_id,
        form_tp_code
    FROM {{ ref('atm_inspection_team') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_INSPECTION_TEAM'
),

ex_te AS (
    SELECT
        examination_team_id,
        form_tp_code
    FROM {{ ref('atm_examination_team') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_EXAMINATION_TEAM'
)

SELECT
    CAST(pe_de_su.pd_subject_code AS string)                AS pd_subject_code,
    CAST(vi_ca.violation_case_code AS string)               AS violation_case_code,
    CAST(pe_de_su.subject_nm AS string)                     AS subject_nm,
    CAST(pe_de_su.subject_tp_code AS string)                AS subject_tp_code,
    CAST(
        CASE WHEN vi_ca.inspection_team_id IS NOT NULL THEN 
            (CASE WHEN in_te.form_tp_code  = 'UNSCHEDULED' THEN 'Đột xuất'
                WHEN in_te.form_tp_code = 'PERIODIC' THEN 'Định kỳ'
                ELSE 'Khác'
            END)
            WHEN vi_ca.examination_team_id IS NOT NULL THEN 
            (CASE WHEN ex_te.form_tp_code  = 'UNSCHEDULED' THEN 'Đột xuất'
                WHEN ex_te.form_tp_code = 'PERIODIC' THEN 'Định kỳ'
                ELSE 'Khác'
            END)
            ELSE 'Khác' 
        END
    AS string)                                              AS form_tp_code,
    CAST(
        CASE
            WHEN vi_ca.life_cycle_status_code = 'NEW'             THEN 'Mới tiếp nhận'
            WHEN vi_ca.life_cycle_status_code = 'PROCESSING'      THEN 'Đang xử lý'
            WHEN vi_ca.life_cycle_status_code = 'DECISION_ISSUED' THEN 'Đã ban hành quyết định'
            WHEN vi_ca.life_cycle_status_code = 'ENFORCED'        THEN 'Đang cưỡng chế'
            WHEN vi_ca.life_cycle_status_code = 'CLOSED'          THEN 'Đã kết thúc'
            ELSE 'Khác'
        END
    AS string)                                              AS life_cycle_status_code,
    CAST(pe_de.issued_dt AS date)                           AS issued_dt,
    CAST(YEAR(pe_de.issued_dt) AS int)                      AS issued_year,
    CAST(pe_de_su.total_fine_amt AS decimal(23,2))          AS total_fine_amt,
    CAST(pe_de_su.src_stm_code AS string)                   AS src_stm_code
FROM pe_de_su
LEFT JOIN pe_de
    ON pe_de.pd_id = pe_de_su.pd_id
LEFT JOIN vi_ca
    ON vi_ca.violation_case_id = pe_de.violation_case_id
LEFT JOIN in_te
    ON in_te.inspection_team_id = vi_ca.inspection_team_id
LEFT JOIN ex_te
    ON ex_te.examination_team_id = vi_ca.examination_team_id
