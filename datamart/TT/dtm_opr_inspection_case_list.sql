/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_inspection_case_list
* Program name: Operational Inspection Case List
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-01   tuan.nguyenvanb   [LLD 2026-10-01, BA STT 5] status_code: start = COALESCE(start_dt, ky tu ngay),
*                       end = COALESCE(end_dt, ky den ngay); co start va (end NULL hoac end > etl_date) -> IN_PROGRESS;
*                       co start va end <= etl_date -> COMPLETED; ca 2 NULL -> NOT_STARTED. Gia tri phu thuoc NGAY ETL
*                       (sysdate trong SQL BA) -> can nap lai hang ngay. Cot dau ra KHONG doi.
*--------------------------------------------------------------------*
*/

WITH in_te_tg AS (
    SELECT
        inspection_team_target_code,
        inspection_team_code,
        target_nm,
        target_tp_code,
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
        COALESCE(start_dt, inspection_period_from_dt) AS effective_start_dt,
        COALESCE(end_dt, inspection_period_to_dt)     AS effective_end_dt,
        decision_dt
    FROM {{ ref('atm_inspection_team') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'THANHTRA_INSPECTION_TEAM'
)

SELECT
    CAST(in_te_tg.inspection_team_target_code AS string)    AS inspection_team_target_code,
    CAST(in_te_tg.inspection_team_code AS string)           AS inspection_team_code,
    CAST(in_te_tg.target_nm AS string)                      AS target_nm,
    CAST(in_te_tg.target_tp_code AS string)                 AS target_tp_code,
    CAST(in_te.form_tp_code AS string)                      AS form_tp_code,
    CAST(
        CASE
            WHEN in_te.effective_start_dt IS NOT NULL AND in_te.effective_end_dt IS NULL                                      THEN 'IN_PROGRESS'
            WHEN in_te.effective_start_dt IS NOT NULL AND in_te.effective_end_dt >  to_date('{{ var("etl_date") }}','yyyy-MM-dd') THEN 'IN_PROGRESS'
            WHEN in_te.effective_start_dt IS NOT NULL AND in_te.effective_end_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd') THEN 'COMPLETED'
            WHEN in_te.effective_start_dt IS NULL     AND in_te.effective_end_dt IS NULL                                      THEN 'NOT_STARTED'
        END
    AS string)                                              AS status_code,
    CAST(in_te.decision_dt AS date)                         AS decision_dt,
    CAST(YEAR(in_te.decision_dt) AS int)                    AS decision_year,
    CAST(in_te_tg.src_stm_code AS string)                   AS src_stm_code
FROM in_te_tg
INNER JOIN in_te
    ON in_te.inspection_team_id = in_te_tg.inspection_team_id
