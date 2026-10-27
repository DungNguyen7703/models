/*
*--------------------------------------------------------------------*
* Program code: ods_vsdc_foreign_investor_info
* Program name: ODS VSDC.FOREIGN_INVESTOR_INFO
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(ticker_symbol AS string)                        AS ticker_symbol
    , CAST(isin_code AS string)                          AS isin_code
    , CAST(total_issued_shares AS bigint)                AS total_issued_shares
    , CAST(max_foreign_ownership_ratio AS decimal(10,2)) AS max_foreign_ownership_ratio
    , CAST(max_shares_foreign_can_hold AS bigint)        AS max_shares_foreign_can_hold
    , CAST(current_shares_foreign_hold AS bigint)        AS current_shares_foreign_hold
    , CAST(remaining_shares_foreign_can_hold AS bigint)  AS remaining_shares_foreign_can_hold
    , CAST(ds_snpst_dt AS date)                          AS ds_snpst_dt
FROM {{ source('source_vsdc', 'raw_foreign_investor_info') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
