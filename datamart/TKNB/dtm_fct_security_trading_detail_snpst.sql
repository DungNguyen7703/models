/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_security_trading_detail_snpst
* Program name: Fact Security Trading Detail Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Ghi chu:
* - TKNB Nhom 28 - thay the Security Trading Detail Report BM035
*   (bm035mss_*_rpt, da bo khoi LLD). LLD
*   DTM_TKNB_fct_security_trading_detail_snpst.csv (commit 44b2f5e7,
*   2026-10-06). Grain: 1 dong / symbol / trading_dt, moi san.
* - Driving: atm_security_trading_snapshot loc trading_dt = etl_date
*   (literal LLD). Dedup 1 dong/symbol theo trading_time DESC giong
*   dtm_security_trading_snpst_dim (GSTT) - tranh nhan doi cac SUM.
* - security_trading_snpst_dim_id: lookup dtm_security_trading_snpst_dim
*   (model GSTT, dung chung) _hstr theo symbol. INNER JOIN vi cot NOT NULL.
* - atm_securities_order / atm_securities_trade: loc trade_dt = etl_date,
*   ghep ma theo security_symbol_code IN (symbol, isin_code) (literal LLD).
*   Cong don truoc theo security_symbol_code roi moi ghep vao driving -
*   tuong duong toan hoc voi LEFT JOIN + SUM tren tung lenh.
* - Board (literal LLD Nhom 28): khop lenh G1,G2,G3,G4,G7,G8; thoa thuan
*   T1,T2,T3,T4,TR; lo le G4. Khac dtm_fct_market_trading_snpst (thoa thuan
*   T1..T4,T6,R1) - giu theo LLD.
* - NDTNN: *_foreign_investor_tp_code <> '00' (Nhom 29 dung IN ('10','20'));
*   Tu doanh: *_client_house_cl_code = '30'.
* - foreign_ownership_info: LEFT JOIN ticker_symbol = symbol,
*   ds_snpst_dt = trading_dt. remaining_foreign_ownership_ratio =
*   remaining_foreign_holding_quantity / total_issued_share_quantity * 100,
*   NULLIF tranh chia 0.
* - snpst_dt_dim_id = date_format(trading_dt,'yyyyMMdd') theo convention,
*   khong JOIN vat ly dtm_cdr_dt_dim.
*--------------------------------------------------------------------*
*/

WITH se_tr_sn_all AS (
    SELECT
        symbol,
        isin_code,
        trading_dt,
        symbol_status_code,
        reference_price,
        ceiling_price,
        floor_price,
        close_price,
        average_price,
        high_price,
        low_price,
        src_stm_code,
        ROW_NUMBER() OVER (
            PARTITION BY symbol
            ORDER BY trading_time DESC)
        AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'MDDS_JAD_STOCKINFOR'
),

se_tr_sn AS (
    SELECT
        symbol,
        isin_code,
        trading_dt,
        symbol_status_code,
        reference_price,
        ceiling_price,
        floor_price,
        close_price,
        average_price,
        high_price,
        low_price,
        src_stm_code
    FROM se_tr_sn_all
    WHERE rn = 1
),

se_tr_sn_di AS (
    SELECT
        security_trading_snpst_dim_id,
        symbol
    FROM {{ ref('dtm_security_trading_snpst_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'MDDS_JAD_STOCKINFOR'
),

order_agg AS (
    SELECT
        trade_dt,
        security_symbol_code,
        SUM(CASE WHEN side_ind = 'B' AND order_action_tp_code = 'N' THEN 1
                 WHEN side_ind = 'B' AND order_action_tp_code = 'C' THEN -1
                 ELSE 0 END)                                                        AS buy_order_cnt,
        SUM(CASE WHEN side_ind = 'B' AND order_action_tp_code = 'N' THEN order_vol ELSE 0 END) AS buy_order_vol,
        SUM(CASE WHEN side_ind = 'S' AND order_action_tp_code = 'N' THEN 1
                 WHEN side_ind = 'S' AND order_action_tp_code = 'C' THEN -1
                 ELSE 0 END)                                                        AS sell_order_cnt,
        SUM(CASE WHEN side_ind = 'S' AND order_action_tp_code = 'N' THEN order_vol ELSE 0 END) AS sell_order_vol
    FROM {{ ref('atm_securities_order') }}
    WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    GROUP BY
        trade_dt,
        security_symbol_code
),

trade_agg AS (
    SELECT
        trade_dt,
        security_symbol_code,
        -- Theo phuong thuc giao dich
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN execution_vol ELSE 0 END) AS matched_trading_vol,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN execution_val ELSE 0 END) AS matched_trading_val,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','T4','TR') THEN execution_vol ELSE 0 END)      AS negotiated_trading_vol,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','T4','TR') THEN execution_val ELSE 0 END)      AS negotiated_trading_val,
        SUM(CASE WHEN board_tp_code IN ('G4') THEN execution_vol ELSE 0 END)                          AS odd_lot_trading_vol,
        SUM(CASE WHEN board_tp_code IN ('G4') THEN execution_val ELSE 0 END)                          AS odd_lot_trading_val,
        SUM(execution_vol)                                                                            AS total_trading_vol,
        SUM(execution_val)                                                                            AS total_trading_val,
        -- NDTNN tong
        SUM(CASE WHEN buy_foreign_investor_tp_code <> '00' THEN execution_vol ELSE 0 END)  AS foreign_investor_total_buy_vol,
        SUM(CASE WHEN sell_foreign_investor_tp_code <> '00' THEN execution_vol ELSE 0 END) AS foreign_investor_total_sell_vol,
        SUM(CASE WHEN buy_foreign_investor_tp_code <> '00' THEN execution_val ELSE 0 END)  AS foreign_investor_total_buy_val,
        SUM(CASE WHEN sell_foreign_investor_tp_code <> '00' THEN execution_val ELSE 0 END) AS foreign_investor_total_sell_val,
        -- NDTNN thoa thuan
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','T4','TR') AND buy_foreign_investor_tp_code <> '00' THEN execution_vol ELSE 0 END)  AS foreign_investor_negotiated_buy_vol,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','T4','TR') AND sell_foreign_investor_tp_code <> '00' THEN execution_vol ELSE 0 END) AS foreign_investor_negotiated_sell_vol,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','T4','TR') AND buy_foreign_investor_tp_code <> '00' THEN execution_val ELSE 0 END)  AS foreign_investor_negotiated_buy_val,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','T4','TR') AND sell_foreign_investor_tp_code <> '00' THEN execution_val ELSE 0 END) AS foreign_investor_negotiated_sell_val,
        -- NDTNN khop lenh
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G4','G7','G8') AND buy_foreign_investor_tp_code <> '00' THEN execution_vol ELSE 0 END)  AS foreign_investor_matched_buy_vol,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G4','G7','G8') AND sell_foreign_investor_tp_code <> '00' THEN execution_vol ELSE 0 END) AS foreign_investor_matched_sell_vol,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G4','G7','G8') AND buy_foreign_investor_tp_code <> '00' THEN execution_val ELSE 0 END)  AS foreign_investor_matched_buy_val,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G4','G7','G8') AND sell_foreign_investor_tp_code <> '00' THEN execution_val ELSE 0 END) AS foreign_investor_matched_sell_val,
        -- Tu doanh tong
        SUM(CASE WHEN buy_client_house_cl_code = '30' THEN execution_vol ELSE 0 END)  AS proprietary_total_buy_vol,
        SUM(CASE WHEN sell_client_house_cl_code = '30' THEN execution_vol ELSE 0 END) AS proprietary_total_sell_vol,
        SUM(CASE WHEN buy_client_house_cl_code = '30' THEN execution_val ELSE 0 END)  AS proprietary_total_buy_val,
        SUM(CASE WHEN sell_client_house_cl_code = '30' THEN execution_val ELSE 0 END) AS proprietary_total_sell_val,
        -- Tu doanh thoa thuan
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','T4','TR') AND buy_client_house_cl_code = '30' THEN execution_vol ELSE 0 END)  AS proprietary_negotiated_buy_vol,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','T4','TR') AND sell_client_house_cl_code = '30' THEN execution_vol ELSE 0 END) AS proprietary_negotiated_sell_vol,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','T4','TR') AND buy_client_house_cl_code = '30' THEN execution_val ELSE 0 END)  AS proprietary_negotiated_buy_val,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','T4','TR') AND sell_client_house_cl_code = '30' THEN execution_val ELSE 0 END) AS proprietary_negotiated_sell_val,
        -- Tu doanh khop lenh
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G4','G7','G8') AND buy_client_house_cl_code = '30' THEN execution_vol ELSE 0 END)  AS proprietary_matched_buy_vol,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G4','G7','G8') AND sell_client_house_cl_code = '30' THEN execution_vol ELSE 0 END) AS proprietary_matched_sell_vol,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G4','G7','G8') AND buy_client_house_cl_code = '30' THEN execution_val ELSE 0 END)  AS proprietary_matched_buy_val,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G4','G7','G8') AND sell_client_house_cl_code = '30' THEN execution_val ELSE 0 END) AS proprietary_matched_sell_val
    FROM {{ ref('atm_securities_trade') }}
    WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
    GROUP BY
        trade_dt,
        security_symbol_code
),

order_summary AS (
    SELECT
        se_tr_sn.symbol,
        SUM(order_agg.buy_order_cnt)  AS buy_order_cnt,
        SUM(order_agg.buy_order_vol)  AS buy_order_vol,
        SUM(order_agg.sell_order_cnt) AS sell_order_cnt,
        SUM(order_agg.sell_order_vol) AS sell_order_vol
    FROM se_tr_sn
    INNER JOIN order_agg
        ON order_agg.trade_dt = se_tr_sn.trading_dt
        AND order_agg.security_symbol_code IN (se_tr_sn.symbol, se_tr_sn.isin_code)
    GROUP BY
        se_tr_sn.symbol
),

trade_summary AS (
    SELECT
        se_tr_sn.symbol,
        SUM(trade_agg.matched_trading_vol)                  AS matched_trading_vol,
        SUM(trade_agg.matched_trading_val)                  AS matched_trading_val,
        SUM(trade_agg.negotiated_trading_vol)               AS negotiated_trading_vol,
        SUM(trade_agg.negotiated_trading_val)               AS negotiated_trading_val,
        SUM(trade_agg.odd_lot_trading_vol)                  AS odd_lot_trading_vol,
        SUM(trade_agg.odd_lot_trading_val)                  AS odd_lot_trading_val,
        SUM(trade_agg.total_trading_vol)                    AS total_trading_vol,
        SUM(trade_agg.total_trading_val)                    AS total_trading_val,
        SUM(trade_agg.foreign_investor_total_buy_vol)       AS foreign_investor_total_buy_vol,
        SUM(trade_agg.foreign_investor_total_sell_vol)      AS foreign_investor_total_sell_vol,
        SUM(trade_agg.foreign_investor_total_buy_val)       AS foreign_investor_total_buy_val,
        SUM(trade_agg.foreign_investor_total_sell_val)      AS foreign_investor_total_sell_val,
        SUM(trade_agg.foreign_investor_negotiated_buy_vol)  AS foreign_investor_negotiated_buy_vol,
        SUM(trade_agg.foreign_investor_negotiated_sell_vol) AS foreign_investor_negotiated_sell_vol,
        SUM(trade_agg.foreign_investor_negotiated_buy_val)  AS foreign_investor_negotiated_buy_val,
        SUM(trade_agg.foreign_investor_negotiated_sell_val) AS foreign_investor_negotiated_sell_val,
        SUM(trade_agg.foreign_investor_matched_buy_vol)     AS foreign_investor_matched_buy_vol,
        SUM(trade_agg.foreign_investor_matched_sell_vol)    AS foreign_investor_matched_sell_vol,
        SUM(trade_agg.foreign_investor_matched_buy_val)     AS foreign_investor_matched_buy_val,
        SUM(trade_agg.foreign_investor_matched_sell_val)    AS foreign_investor_matched_sell_val,
        SUM(trade_agg.proprietary_total_buy_vol)            AS proprietary_total_buy_vol,
        SUM(trade_agg.proprietary_total_sell_vol)           AS proprietary_total_sell_vol,
        SUM(trade_agg.proprietary_total_buy_val)            AS proprietary_total_buy_val,
        SUM(trade_agg.proprietary_total_sell_val)           AS proprietary_total_sell_val,
        SUM(trade_agg.proprietary_negotiated_buy_vol)       AS proprietary_negotiated_buy_vol,
        SUM(trade_agg.proprietary_negotiated_sell_vol)      AS proprietary_negotiated_sell_vol,
        SUM(trade_agg.proprietary_negotiated_buy_val)       AS proprietary_negotiated_buy_val,
        SUM(trade_agg.proprietary_negotiated_sell_val)      AS proprietary_negotiated_sell_val,
        SUM(trade_agg.proprietary_matched_buy_vol)          AS proprietary_matched_buy_vol,
        SUM(trade_agg.proprietary_matched_sell_vol)         AS proprietary_matched_sell_vol,
        SUM(trade_agg.proprietary_matched_buy_val)          AS proprietary_matched_buy_val,
        SUM(trade_agg.proprietary_matched_sell_val)         AS proprietary_matched_sell_val
    FROM se_tr_sn
    INNER JOIN trade_agg
        ON trade_agg.trade_dt = se_tr_sn.trading_dt
        AND trade_agg.security_symbol_code IN (se_tr_sn.symbol, se_tr_sn.isin_code)
    GROUP BY
        se_tr_sn.symbol
),

fo_ow_in AS (
    SELECT
        ticker_symbol,
        ds_snpst_dt,
        max_foreign_ownership_ratio,
        remaining_foreign_holding_quantity,
        total_issued_share_quantity
    FROM {{ ref('atm_foreign_ownership_info') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'VSDC_FOREIGN_INVESTOR_INFO'
)

SELECT
    CAST(date_format(se_tr_sn.trading_dt, 'yyyyMMdd') AS string)                AS snpst_dt_dim_id,
    CAST(se_tr_sn_di.security_trading_snpst_dim_id AS string)                  AS security_trading_snpst_dim_id,
    CAST(se_tr_sn.symbol_status_code AS string)                                AS trading_status_code,
    CAST(se_tr_sn.reference_price AS decimal(23,2))                            AS reference_price,
    CAST(se_tr_sn.ceiling_price AS decimal(23,2))                              AS ceiling_price,
    CAST(se_tr_sn.floor_price AS decimal(23,2))                                AS floor_price,
    CAST(se_tr_sn.close_price AS decimal(23,2))                                AS close_price,
    CAST(se_tr_sn.average_price AS decimal(23,2))                              AS average_price,
    CAST(se_tr_sn.high_price AS decimal(23,2))                                 AS high_price,
    CAST(se_tr_sn.low_price AS decimal(23,2))                                  AS low_price,
    CAST(order_summary.buy_order_cnt AS int)                                   AS buy_order_cnt,
    CAST(order_summary.buy_order_vol AS bigint)                                AS buy_order_vol,
    CAST(order_summary.sell_order_cnt AS int)                                  AS sell_order_cnt,
    CAST(order_summary.sell_order_vol AS bigint)                               AS sell_order_vol,
    CAST(trade_summary.matched_trading_vol AS bigint)                          AS matched_trading_vol,
    CAST(trade_summary.matched_trading_val AS decimal(23,2))                   AS matched_trading_val,
    CAST(trade_summary.negotiated_trading_vol AS bigint)                       AS negotiated_trading_vol,
    CAST(trade_summary.negotiated_trading_val AS decimal(23,2))                AS negotiated_trading_val,
    CAST(trade_summary.odd_lot_trading_vol AS bigint)                          AS odd_lot_trading_vol,
    CAST(trade_summary.odd_lot_trading_val AS decimal(23,2))                   AS odd_lot_trading_val,
    CAST(trade_summary.total_trading_vol AS bigint)                            AS total_trading_vol,
    CAST(trade_summary.total_trading_val AS decimal(23,2))                     AS total_trading_val,
    CAST(fo_ow_in.max_foreign_ownership_ratio AS decimal(9,4))                 AS max_foreign_ownership_ratio,
    CAST(CAST(fo_ow_in.remaining_foreign_holding_quantity AS decimal(23,4))
        / NULLIF(CAST(fo_ow_in.total_issued_share_quantity AS decimal(23,4)), 0) * 100
        AS decimal(9,4))                                                       AS remaining_foreign_ownership_ratio,
    CAST(trade_summary.foreign_investor_total_buy_vol AS bigint)               AS foreign_investor_total_buy_vol,
    CAST(trade_summary.foreign_investor_total_sell_vol AS bigint)              AS foreign_investor_total_sell_vol,
    CAST(trade_summary.foreign_investor_total_buy_val AS decimal(23,2))        AS foreign_investor_total_buy_val,
    CAST(trade_summary.foreign_investor_total_sell_val AS decimal(23,2))       AS foreign_investor_total_sell_val,
    CAST(trade_summary.foreign_investor_negotiated_buy_vol AS bigint)          AS foreign_investor_negotiated_buy_vol,
    CAST(trade_summary.foreign_investor_negotiated_sell_vol AS bigint)         AS foreign_investor_negotiated_sell_vol,
    CAST(trade_summary.foreign_investor_negotiated_buy_val AS decimal(23,2))   AS foreign_investor_negotiated_buy_val,
    CAST(trade_summary.foreign_investor_negotiated_sell_val AS decimal(23,2))  AS foreign_investor_negotiated_sell_val,
    CAST(trade_summary.foreign_investor_matched_buy_vol AS bigint)             AS foreign_investor_matched_buy_vol,
    CAST(trade_summary.foreign_investor_matched_sell_vol AS bigint)            AS foreign_investor_matched_sell_vol,
    CAST(trade_summary.foreign_investor_matched_buy_val AS decimal(23,2))      AS foreign_investor_matched_buy_val,
    CAST(trade_summary.foreign_investor_matched_sell_val AS decimal(23,2))     AS foreign_investor_matched_sell_val,
    CAST(trade_summary.proprietary_total_buy_vol AS bigint)                    AS proprietary_total_buy_vol,
    CAST(trade_summary.proprietary_total_sell_vol AS bigint)                   AS proprietary_total_sell_vol,
    CAST(trade_summary.proprietary_total_buy_val AS decimal(23,2))             AS proprietary_total_buy_val,
    CAST(trade_summary.proprietary_total_sell_val AS decimal(23,2))            AS proprietary_total_sell_val,
    CAST(trade_summary.proprietary_negotiated_buy_vol AS bigint)               AS proprietary_negotiated_buy_vol,
    CAST(trade_summary.proprietary_negotiated_sell_vol AS bigint)              AS proprietary_negotiated_sell_vol,
    CAST(trade_summary.proprietary_negotiated_buy_val AS decimal(23,2))        AS proprietary_negotiated_buy_val,
    CAST(trade_summary.proprietary_negotiated_sell_val AS decimal(23,2))       AS proprietary_negotiated_sell_val,
    CAST(trade_summary.proprietary_matched_buy_vol AS bigint)                  AS proprietary_matched_buy_vol,
    CAST(trade_summary.proprietary_matched_sell_vol AS bigint)                 AS proprietary_matched_sell_vol,
    CAST(trade_summary.proprietary_matched_buy_val AS decimal(23,2))           AS proprietary_matched_buy_val,
    CAST(trade_summary.proprietary_matched_sell_val AS decimal(23,2))          AS proprietary_matched_sell_val,
    CAST(se_tr_sn.src_stm_code AS string)                                      AS src_stm_code
FROM se_tr_sn
INNER JOIN se_tr_sn_di
    ON se_tr_sn_di.symbol = se_tr_sn.symbol
LEFT JOIN order_summary
    ON order_summary.symbol = se_tr_sn.symbol
LEFT JOIN trade_summary
    ON trade_summary.symbol = se_tr_sn.symbol
LEFT JOIN fo_ow_in
    ON fo_ow_in.ticker_symbol = se_tr_sn.symbol
    AND fo_ow_in.ds_snpst_dt = se_tr_sn.trading_dt
