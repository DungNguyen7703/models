-- Program code: pttt_fct_macro_indicator_snpst_flat
-- Program name: Flat table Fact Macro Indicator Snapshot
-- Source mart model: dtm_fct_macro_indicator_snpst
-- Joined dimension: dtm_cdr_dt_dim for calendar date
-- Grain: 1 row per macro indicator per snapshot day
-- Filter: only the snapshot day equal to etl_date
-- Note: This model selects calendar columns from dtm_cdr_dt_dim directly, so it has no snpst_cdr_dt column.
-- Modified: 2026-10-15 add header comment, no logic change

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.macro_indicator_code,
    f.macro_indicator_name,
    f.period_tp_code,
    f.period_label,
    f.indicator_val,
    f.prev_period_val,
    f.pct_change,
    f.yoy_pct_change,
    f.ma_n_val,
    f.src_stm_code,
    cal.cdr_dt,
    cal.year,
    cal.quarter,
    cal.month,
    cal.day_of_week,
    cal.is_weekend,
    cal.holiday_flag,
    cal.is_trading_date
FROM {{ ref('dtm_fct_macro_indicator_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
