/*
*--------------------------------------------------------------------*
* Program code: atm_index_constituent_snapshot
* Program name: Atomic Index Constituent Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ja_cs AS (
    SELECT
        id
        , indexcode
        , indexid
        , symbol
        , tradingdate
        , adddate
        , floorcode
        , totalqtty
    FROM {{ ref('ods_mdds_jad_csidxinfor') }}
    WHERE TRADINGDATE = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('MDDS_JAD_CSIDXINFOR', "ja_cs.id") }} AS index_constituent_snpst_id
    , CAST(ja_cs.id AS string)                                             AS index_constituent_snpst_code
    , CAST('MDDS_JAD_CSIDXINFOR' AS string)                                AS src_stm_code
    , CAST(ja_cs.indexcode AS string)                                      AS index_code
    , CAST(ja_cs.indexid AS string)                                        AS index_id
    , CAST(ja_cs.symbol AS string)                                         AS symbol
    , CAST(ja_cs.tradingdate AS date)                                      AS trading_dt
    , CAST(ja_cs.adddate AS date)                                          AS add_dt
    , CAST(ja_cs.floorcode AS string)                                      AS floor_code
    , CAST(ja_cs.totalqtty AS int)                                         AS total_match_vol
FROM ja_cs