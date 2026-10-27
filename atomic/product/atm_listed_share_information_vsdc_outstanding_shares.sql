/*
*--------------------------------------------------------------------*
* Program code: atm_listed_share_information_vsdc_outstanding_shares
* Program name: Atomic Listed Share Info – VSDC.OUTSTANDING_SHARES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-22		tuan.nguyenvanb		[DONG BO DESIGN 2026-10-21] entity listed_share_info -> listed_share_information; cot listed_share_information_id,
*									issuer_name->issuer_nm, transaction_date->transaction_dt; them rpt_dt (REPORT_DATE, chi HNX/HOSE) o CUOI SELECT.
*									Bang vat ly: RENAME TABLE/COLUMN + ADD COLUMN rpt_dt AFTER transaction_dt (scratch/alter_atomic_rename_20261022.sql) TRUOC khi chay.
*--------------------------------------------------------------------*
*/

WITH ou_sh AS (
    SELECT
        ticker_symbol
        , isin_code
        , total_issued_shares
        , treasury_shares
        , outstanding_shares
        , free_float_shares
        , restricted_shares
        , voting_shares
        , transaction_dt
        , ds_snpst_dt
    FROM {{ ref('ods_vsdc_outstanding_shares') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('VSDC_OUTSTANDING_SHARES', "ou_sh.ticker_symbol") }} AS listed_share_information_id
    , CAST(ou_sh.ticker_symbol AS string)          AS ticker_symbol
    , CAST('VSDC_OUTSTANDING_SHARES' AS string)    AS src_stm_code
    , CAST(ou_sh.isin_code AS string)              AS isin_code
    , CAST(ou_sh.total_issued_shares AS bigint)    AS total_issued_share_quantity
    , CAST(ou_sh.treasury_shares AS bigint)        AS treasury_share_quantity
    , CAST(ou_sh.outstanding_shares AS bigint)     AS outstanding_share_quantity
    , CAST(ou_sh.free_float_shares AS bigint)      AS free_float_share_quantity
    , CAST(ou_sh.restricted_shares AS bigint)      AS restricted_share_quantity
    , CAST(ou_sh.voting_shares AS bigint)          AS voting_share_quantity
    , CAST(NULL AS string)                         AS issuer_nm
    , CAST(NULL AS bigint)                         AS listed_share_quantity
    , CAST(NULL AS decimal(23,2))                  AS reference_price
    , CAST(ou_sh.transaction_dt AS date)           AS transaction_dt
    , CAST(NULL AS date)                           AS rpt_dt
FROM ou_sh
