/*
*--------------------------------------------------------------------*
* Program code: stg_mdds_jad_translog
* Program name: Staging MDDS.JAD_TRANSLOG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(kid AS string)                      AS kid
    , CAST(sequencemsg AS string)            AS sequencemsg
    , to_date(tradingdate, 'dd/MM/yyyy')      AS tradingdate
    , CAST(symbol AS string)                 AS symbol
    , CAST(formattedtime AS string)          AS formattedtime
    , CAST(lastcolor AS string)              AS lastcolor
    , CAST(formattedmatchprice AS double)    AS formattedmatchprice
    , CAST(changecolor AS string)            AS changecolor
    , CAST(formattedvol AS bigint)           AS formattedvol
    , CAST(formattedaccvol AS bigint)        AS formattedaccvol
    , CAST(formattedaccval AS double)        AS formattedaccval
    , CAST(totalbuyvol AS bigint)            AS totalbuyvol
    , CAST(totalsellvol AS bigint)           AS totalsellvol
    , CAST(boardid AS string)                AS boardid
    , CAST(formattedchangevalue AS double)   AS formattedchangevalue
FROM {{ source('source_mdds', 'raw_jad_translog') }}
WHERE date_format(to_date(TRADINGDATE,'dd/MM/yyyy'), 'yyyy-MM-dd') = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')