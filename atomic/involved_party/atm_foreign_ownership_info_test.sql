/*
*--------------------------------------------------------------------*
* Program code: atm_foreign_ownership_info_test
* Program name: Atomic Foreign Ownership Info
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

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
    FROM {{ ref('ods_vsdc_foreign_investor_info_test') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
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
FROM fr_iv
