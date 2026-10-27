-- [FIRST-TIME] ft_atm_foreign_ownership_info: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily atm_foreign_ownership_info (config ft_target='foreign_ownership_info', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: atm_foreign_ownership_info
* Program name: Atomic Foreign Ownership Info
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

-- 2026-10-09 tuan.nguyenvanb: [BACKFILL-UAT-NEW] BAN FIRST-TIME (nap lich su 1 lan): bo loc WHERE theo ngay. Dong goc giu o comment BACKFILL-UAT-ORIG.   -- [BACKFILL-UAT-NEW]
{{ config(incremental_strategy='append') }}   -- [BACKFILL-UAT-NEW] first-time: ghi theo ds_snpst_dt cua tung dong (thay strategy snapshot cua yml)
WITH fr_iv AS (
    SELECT
        ticker_symbol
        , isin_code
        , total_issued_shares
        , max_foreign_ownership_ratio
        , max_shares_foreign_can_hold
        , current_shares_foreign_hold
        , remaining_shares_foreign_can_hold
        , ds_snpst_dt
    FROM {{ ft_ref('ft_ods_vsdc_foreign_investor_info') }}
    -- [BACKFILL-UAT-ORIG] WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('VSDC_FOREIGN_INVESTOR_INFO', "fr_iv.ticker_symbol") }} AS foreign_ownership_info_id
    , CAST(fr_iv.ticker_symbol AS string)                       AS ticker_symbol
    , CAST('VSDC_FOREIGN_INVESTOR_INFO' AS string)              AS src_stm_code
    , CAST(fr_iv.isin_code AS string)                           AS isin_code
    , CAST(fr_iv.total_issued_shares AS bigint)                 AS total_issued_share_quantity
    , CAST(fr_iv.max_foreign_ownership_ratio AS decimal(10,2))  AS max_foreign_ownership_ratio
    , CAST(fr_iv.max_shares_foreign_can_hold AS bigint)         AS max_foreign_holding_quantity
    , CAST(fr_iv.current_shares_foreign_hold AS bigint)         AS current_foreign_holding_quantity
    , CAST(fr_iv.remaining_shares_foreign_can_hold AS bigint)   AS remaining_foreign_holding_quantity
    , CAST(fr_iv.ds_snpst_dt AS date) AS ds_snpst_dt  -- [BACKFILL-UAT-NEW] cot ds_snpst_dt (first-time)
FROM fr_iv
