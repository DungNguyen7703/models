/*
*--------------------------------------------------------------------*
* Program code: stg_mdds_jad_csidxinfor
* Program name: Staging MDDS.JAD_CSIDXINFOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)            AS id
    , CAST(indexcode AS string)   AS indexcode
    , CAST(symbol AS string)      AS symbol
    , CAST(totalqtty AS string)   AS totalqtty
    , CAST(adddate AS string)     AS adddate
    , CAST(indexid AS int)        AS indexid
    , CAST(floorcode AS string)   AS floorcode
    , to_date(tradingdate, 'dd/MM/yyyy') AS tradingdate
    , CAST(stockno AS string)     AS stockno
    , CAST(weighted AS string)    AS weighted
FROM {{ source('source_mdds', 'raw_jad_csidxinfor') }}
WHERE date_format(to_date(TRADINGDATE,'dd/MM/yyyy'), 'yyyy-MM-dd') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')