-- ────────────────────────────────────────────────────────────
-- Model : tt_opr_inspection_case_list_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    o.inspection_team_target_code,
    o.inspection_team_code,
    o.target_nm,
    o.target_tp_code,
    o.form_tp_code,
    o.status_code,
    o.decision_dt,
    o.decision_year,
    o.src_stm_code

FROM {{ ref('dtm_opr_inspection_case_list') }}_hstr o
WHERE o.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
  AND o.ds_rcrd_st = 'ACTIVE'  -- 2026-09-29: loai ban ghi INACTIVE (da xoa o nguon) scd4a giu lai trong _hstr