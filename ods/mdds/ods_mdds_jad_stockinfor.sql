/*
*--------------------------------------------------------------------*
* Program code: ods_mdds_jad_stockinfor
* Program name: ODS MDDS.JAD_STOCKINFOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
* 2026-10-08		tuan.nguyenvanb		Bo sung cot VWAP (JAD_STOCKINFOR; BA: bo cac cot duoi M1)
* 2026-10-12		duc.luxuan			ODS = staging as-of etl_date: lay du 83 cot, dung trinh tu + kieu cua staging,
*									khong bien doi; giu cot dan xuat tradingtimestamp sau tradingtime. Bo sung prior_price,
*									openinterestchange, priceone, pricetwo, totalbuyvol, totalsellvol.
*--------------------------------------------------------------------*
*/

SELECT
    historyid
    , kid
    , symbol
    , stockid
    , fullname
    , tradingdate
    , floorcode
    , stocktype
    , ceiling
    , floor
    , reference
    , bidprice3
    , bidvol3
    , bidprice2
    , bidvol2
    , bidprice1
    , bidvol1
    , closeprice
    , closevol
    , change
    , offerprice1
    , offervol1
    , offerprice2
    , offervol2
    , offerprice3
    , offervol3
    , totaltrading
    , totaltradingvalue
    , averageprice
    , open
    , high
    , low
    , foreignbuy
    , foreignsell
    , foreignremain
    , foreignroom
    , total_offer_qtty
    , total_bid_qtty
    , pt_match_qtty
    , pt_match_price
    , pt_total_traded_qtty
    , pt_total_traded_value
    , status
    , tradingsessionid
    , openinterest
    , firsttradingdate
    , lasttradingdate
    , underlyingsymbol
    , issuername
    , coveredwarranttype
    , maturitydate
    , exerciseprice
    , exerciseratio
    , listedshare
    , fundtype
    , totallistingqtty
    , symbolstatuscode
    , symbolisin
    , marketid
    , boardid
    , productgrpid
    , productid
    , lastcolor
    , tradingtime
    , CAST(concat(CAST(tradingdate AS string), ' ', tradingtime) AS timestamp) AS tradingtimestamp
    , couponrate
    , yield
    , issuedate
    , settlementprice
    , maturitymonthyear
    , listingdate
    , contractmultiplier
    , putorcall
    , exercisestyle
    , prior_price
    , foreignbuyval
    , foreignsellval
    , openinterestchange
    , priceone
    , pricetwo
    , sequence
    , totalbuyvol
    , totalsellvol
    , vwap
FROM {{ ref('stg_mdds_jad_stockinfor') }}
WHERE tradingdate = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
