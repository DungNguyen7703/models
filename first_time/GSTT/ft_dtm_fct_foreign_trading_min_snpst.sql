-- [FIRST-TIME] ft_dtm_fct_foreign_trading_min_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_foreign_trading_min_snpst (config ft_target='fct_foreign_trading_min_snpst', macro macros/first_time).
/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_foreign_trading_min_snpst
* Program name: Dtm Fct Foreign Trading Min Snpst
* Created by: tuan.nguyenvanb
* Created date: 2026-09-21
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-21		tuan.nguyenvanb		[MOI, theo LLD DTM_GSTT_fct_foreign_trading_min_
*                                       snpst.csv, O_GSTT_8] Fact GD NDTNN theo PHUT - 1
*                                       dong / ma CK / phut giao dich (Trade Minute =
*                                       DATE_TRUNC('minute', Trade Timestamp)). Nguon
*                                       atm_securities_trade DA CO SAN cot trade_tms (dong
*                                       nghiep bo sung 2026-09-04 - CANH BAO: dinh dang
*                                       TRADE_TIME cua HNX chua duoc Data Modeler/DBA xac
*                                       nhan 100% mau that, xem chi tiet o
*                                       atm_securities_trade_ordertrade_trade_book_hnx.sql).
*                                       Join sang Security Trading Snapshot Dimension qua
*                                       trade_join_symbol (CASE floor_code IN ('02','04','03')
*                                       THEN isin_code ELSE symbol END) - dung quy uoc chung
*                                       cua GSTT vi atm_securities_trade.security_symbol_code
*                                       da duoc chuan hoa theo dung khoa nay o tang atomic
*                                       (isin_code cho HNX/UPCOM/FDS, symbol cho HOSE).
*                                       snpst_dt_dim_id format truc tiep tu trade_dt (khong
*                                       join dtm_cdr_dt_dim), dung quy uoc chung GSTT.
*                                       foreign_buy_val_at_min/foreign_sell_val_at_min tinh
*                                       bang SUM(CASE WHEN ...) 1 lan quet thay vi 2 INNER
*                                       JOIN rieng nhu LLD viet literal - tuong duong ve mat
*                                       so hoc, tranh quet atm_securities_trade 2 lan.
*                                       LUU Y VAN HANH: bang nay grain rat min (per-minute),
*                                       khoi luong du lieu lon hon nhieu so cac Fact "_snpst"
*                                       theo-ngay khac - da duoc Design xac nhan van can
*                                       (truoc do danh gia khong dung, nay xac nhan lai can).
* 2026-10-08		tuan.nguyenvanb		[BACKFILL-UAT-NEW] TAM THOI: doc bang scd4a tu bang MAIN thay vi <bang>_hstr (bo loc ds_snpst_dt).
*                                       Dong goc duoc giu o dang comment BACKFILL-UAT-ORIG. Chuyen che do daily bang dbt/first_time_mode.py [BACKFILL-UAT-NEW]
*                                       de tra ve nguyen ban sau khi chay xong du lieu 1 nam. [BACKFILL-UAT-NEW]
* 2026-10-12		tuan.nguyenvanb		[LLD GSTT d1e944ee, O_GSTT_41 muc 4] VIET LAI: nguon Security Trading Snapshot (MDDS
*                                       JAD_STOCKINFOR) thay Securities Trade. GT NDTNN mua/ban LUY KE cuoi phut (snapshot cuoi
*                                       phut theo trading_tms, sequence), carry-forward phut trong; lookup dim theo symbol.
*                                       Khong doi cot/kieu -> khong ALTER fact/flat. Can atomic co foreign_buy_val/foreign_sell_val.
* 2026-10-18		tuan.nguyenvanb		[FIX dim_id NULL o ma INACTIVE tai dim MAIN] noi dim security_trading_snpst_dim bang _hstr theo NGAY (ds_snpst_dt = ngay giao dich) thay vi MAIN ACTIVE. Khong doi cot.
* 2026-10-22		tuan.nguyenvanb		Doi tham chieu snapshot.symbol->ticker_symbol, security_full_nm->full_nm. Khong doi cot/kieu.
* 2026-10-22		tuan.nguyenvanb		[VIET LAI, dong bo daily, LLD v4.56-v4.57, BA STT 25/26] Nguon quay lai Securities Trade (ft_atm_securities_trade): GT NDTNN (ky tu thu 4 TK IN F,E)
*                                       PHAT SINH trong phut, khong luy ke, khong carry-forward. Dim join theo ngay (_hstr) voi khoa phu symbol/isin_code (UNION) nhu ft investor_category.
*                                       Khong doi cot.
*--------------------------------------------------------------------*
*/

-- [BACKFILL-UAT-NEW] dim _hstr theo NGAY; moi dong dim -> toi da 2 khoa join (symbol, isin_code), UNION de khong nhan doi khi symbol = isin.
-- Khop ma nhu daily: floor 02/04/03 -> isin_code, con lai -> symbol (equi-join, KHONG dung OR/IN trong ON).
WITH se_tr_sn_di_all AS (
    SELECT security_trading_snpst_dim_id, floor_code, isin_code, symbol, ds_snpst_dt
    FROM {{ ft_ref('ft_dtm_security_trading_snpst_dim') }}_hstr
    WHERE ds_rcrd_st = 'ACTIVE'
),

se_tr_sn_di_key AS (
    SELECT security_trading_snpst_dim_id, symbol AS join_key, ds_snpst_dt FROM se_tr_sn_di_all WHERE symbol IS NOT NULL
    UNION
    SELECT security_trading_snpst_dim_id, isin_code AS join_key, ds_snpst_dt FROM se_tr_sn_di_all WHERE isin_code IS NOT NULL
),

-- Gia tri NDTNN PHAT SINH trong tung phut (Securities Trade). Phut khong co lenh khop thi khong co dong.
se_tr_min AS (
    SELECT
        st.security_symbol_code,
        st.trade_dt,
        date_trunc('minute', st.trade_tms) AS trade_minute_tms,
        SUM(CASE WHEN SUBSTR(st.buy_account_nbr, 4, 1)  IN ('F','E') THEN st.execution_val ELSE 0 END) AS foreign_buy_val_at_min,
        SUM(CASE WHEN SUBSTR(st.sell_account_nbr, 4, 1) IN ('F','E') THEN st.execution_val ELSE 0 END) AS foreign_sell_val_at_min
    FROM {{ ft_ref('ft_atm_securities_trade') }} st
    WHERE st.market_id_code IN ('UPX','STX','STK','STO')
        AND st.src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
        AND st.trade_tms IS NOT NULL
    GROUP BY st.security_symbol_code, st.trade_dt, date_trunc('minute', st.trade_tms)
)

SELECT
    CAST(se_tr_sn_di.security_trading_snpst_dim_id AS string)       AS security_trading_snpst_dim_id,
    CAST(date_format(m.trade_dt, 'yyyyMMdd') AS string)             AS snpst_dt_dim_id,
    CAST(m.trade_minute_tms AS timestamp)                           AS trade_minute_tms,
    CAST(m.foreign_buy_val_at_min AS decimal(23,2))                 AS foreign_buy_val_at_min,
    CAST(m.foreign_sell_val_at_min AS decimal(23,2))                AS foreign_sell_val_at_min
FROM se_tr_min m
LEFT JOIN se_tr_sn_di_key se_tr_sn_di
    ON  se_tr_sn_di.join_key = m.security_symbol_code
    AND se_tr_sn_di.ds_snpst_dt = CAST(m.trade_dt AS date)
