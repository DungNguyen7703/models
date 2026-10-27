/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_examination_case_list
* Program name: Operational Examination Case List
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-18   Claude   Fix theo LLD sua 2026-08-11: examination_team_code
*                       doi nguon tu Examination Team Target sang join
*                       thang Examination Team (khong qua bang con nua)
* 2026-10-01   tuan.nguyenvanb   [LLD 2026-10-01, BA STT 10] status_code: start = COALESCE(start_dt, ky tu ngay),
*                       end = COALESCE(end_dt, ky den ngay); co start va (end NULL hoac end > etl_date) -> IN_PROGRESS;
*                       co start va end <= etl_date -> COMPLETED; ca 2 NULL -> NOT_STARTED. Gia tri phu thuoc NGAY ETL
*                       (sysdate trong SQL BA) -> can nap lai hang ngay. Cot dau ra KHONG doi.
*--------------------------------------------------------------------*
*/

WITH ex_te_tg AS (
    SELECT
        examination_team_target_code,
        target_nm,
        target_tp_code,
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
        examination_team_code,
        form_tp_code,
        COALESCE(start_dt, examination_period_from_dt) AS effective_start_dt,
        COALESCE(end_dt, examination_period_to_dt)     AS effective_end_dt,
        decision_dt
    FROM {{ ref('atm_examination_team') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_EXAMINATION_TEAM'
)

SELECT
    CAST(ex_te_tg.examination_team_target_code AS string)   AS examination_team_target_code,
    CAST(ex_te.examination_team_code AS string)             AS examination_team_code,
    CAST(ex_te_tg.target_nm AS string)                      AS target_nm,
    CAST(ex_te_tg.target_tp_code AS string)                 AS target_tp_code,
    CAST(ex_te.form_tp_code AS string)                      AS form_tp_code,
    CAST(
        CASE
            WHEN ex_te.effective_start_dt IS NOT NULL AND ex_te.effective_end_dt IS NULL                                      THEN 'IN_PROGRESS'
            WHEN ex_te.effective_start_dt IS NOT NULL AND ex_te.effective_end_dt >  to_date('{{ var("etl_date") }}','yyyy-MM-dd') THEN 'IN_PROGRESS'
            WHEN ex_te.effective_start_dt IS NOT NULL AND ex_te.effective_end_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd') THEN 'COMPLETED'
            WHEN ex_te.effective_start_dt IS NULL     AND ex_te.effective_end_dt IS NULL                                      THEN 'NOT_STARTED'
        END
    AS string)                                              AS status_code,
    CAST(ex_te.decision_dt AS date)                         AS decision_dt,
    CAST(YEAR(ex_te.decision_dt) AS int)                    AS decision_year,
    CAST(ex_te_tg.src_stm_code AS string)                   AS src_stm_code
FROM ex_te_tg
INNER JOIN ex_te
    ON ex_te.examination_team_id = ex_te_tg.examination_team_id
