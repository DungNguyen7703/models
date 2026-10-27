-- Program code: pttt_fct_corporate_bond_market_snpst_flat
-- Program name: Flat table Fact Corporate Bond Market Snapshot
-- Source mart model: dtm_fct_corporate_bond_market_snpst
-- Joined dimension: dtm_cdr_dt_dim for calendar date
-- Grain: 1 row per trading day, whole corporate bond market
-- Filter: only the snapshot day equal to etl_date
-- Note: Maturity pressure, outstanding value, trading value and weighted yield, taken as is from the mart.
-- Modified: 2026-10-15 add header comment, no logic change

SELECT /*+ BROADCAST(cal) */
    f.snpst_dt_dim_id,
    f.par_val,
    f.outstanding_vol,
    f.bond_outstanding_val,
    f.maturity_pressure_12_months,
    f.maturity_pressure_12_months_previous,
    f.maturity_pressure_growth_percentage,
    f.bond_trading_val,
    f.bond_yield_weighted_average,
    to_date(f.snpst_dt_dim_id, 'yyyyMMdd') AS snpst_cdr_dt
FROM {{ ref('dtm_fct_corporate_bond_market_snpst') }} f
LEFT JOIN {{ ref('dtm_cdr_dt_dim') }} cal
    ON cal.cdr_dt_dim_id = f.snpst_dt_dim_id
WHERE f.snpst_dt_dim_id = date_format(to_date('{{ var("etl_date") }}','yyyy-MM-dd'), 'yyyyMMdd')
