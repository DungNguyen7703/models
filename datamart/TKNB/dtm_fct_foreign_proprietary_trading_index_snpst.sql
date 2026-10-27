/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_foreign_proprietary_trading_index_snpst
* Program name: Fact Foreign Proprietary Trading Index Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Ghi chu:
* - Thay the Foreign Proprietary Trading Report BM031a (DEPRECATED) - xem
*   DTM_TKNB_Entities.csv. Grain: 1 dong / trade_dt / index_code.
* - atm_securities_trade, atm_index_constituent_snapshot: incremental_rebase
*   /append, KHONG co _hstr, loc truc tiep theo trade_dt/trading_dt.
* - [SUA 2026-09-24 - doi chieu SQL goc BA (BM031a_MSS), theo yeu cau user]:
*   1. securities_trade: bo sung filter market_id_code IN ('STK','STX','UPX')
*      (truoc thieu hoan toan, khac voi dtm_fct_market_trading_snpst.sql).
*   2. proprietary_total_buy/sell_vol/val: BO dieu kien board_tp_code (truoc
*      dung chung cong thuc voi proprietary_matched_*, tuc Total = Matched).
*      Dung theo SQL goc BA: TUDOANH_Tong_* KHONG loc board_tp_code (Total =
*      Khop lenh + Thoa thuan). proprietary_negotiated_/proprietary_matched_*
*      GIU NGUYEN dieu kien board_tp_code (chi 2 cap cot nay moi loc).
*   3. foreign_investor_*: doi dieu kien buy/sell_foreign_investor_tp_code tu
*      "<> '00'" thanh "IN ('10','30')" theo dung SQL goc BA.
*   4. Cach chia theo index_code (constituent-based qua atm_index_constituent_
*      snapshot, JOIN theo symbol) TAM GIU NGUYEN chua doi - BA goc dung
*      floor-based (xem memory project_tknb_ba_query_vs_mart_discrepancies.md
*      muc 4), cho user confirm lai truoc khi doi.
*   5. Sua bug tham chieu sai CTE o cot index_constituent_dim_id (truoc do
*      "index_constituent.index_constituent_dim_id" - CTE index_constituent
*      khong co cot nay va khong nam trong FROM/JOIN cua SELECT cuoi - doi
*      thanh "index_constituent_dim.index_constituent_dim_id" dung CTE da
*      JOIN san o cuoi file).
* - src_stm_code: cung ly do nhu dtm_fct_market_trading_snpst.sql - dung
*   literal gop 'ORDERTRADE_TRADE_BOOK_HOSE_HNX'
*/

WITH index_constituent AS (
    SELECT DISTINCT
        symbol,
        index_code
    FROM {{ ref('atm_index_constituent_snapshot') }}
    WHERE trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'MDDS_JAD_CSIDXINFOR'
),

index_constituent_dim AS (
    SELECT
        index_constituent_dim_id,
        index_code
    FROM {{ ref('dtm_index_constituent_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'MDDS_JAD_CSIDXINFOR'
),

securities_trade AS (
    SELECT
        trade_dt,
        security_symbol_code,
        execution_vol,
        execution_val,
        board_tp_code,
        buy_foreign_investor_tp_code,
        sell_foreign_investor_tp_code,
        buy_client_house_cl_code,
        sell_client_house_cl_code
    FROM {{ ref('atm_securities_trade') }}
    WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
        AND market_id_code IN ('STK','STX','UPX')
),

trade_index AS (
    SELECT
        securities_trade.trade_dt,
        index_constituent.index_code,
        securities_trade.execution_vol,
        securities_trade.execution_val,
        securities_trade.board_tp_code,
        securities_trade.buy_foreign_investor_tp_code,
        securities_trade.sell_foreign_investor_tp_code,
        securities_trade.buy_client_house_cl_code,
        securities_trade.sell_client_house_cl_code
    FROM securities_trade
    INNER JOIN index_constituent
        ON index_constituent.symbol = securities_trade.security_symbol_code
),

trade_summary AS (
    SELECT
        trade_dt,
        index_code,
        SUM(CASE WHEN buy_foreign_investor_tp_code IN ('10','30')  THEN execution_vol ELSE 0 END) AS foreign_investor_total_buy_vol,
        SUM(CASE WHEN sell_foreign_investor_tp_code IN ('10','30') THEN execution_vol ELSE 0 END) AS foreign_investor_total_sell_vol,
        SUM(CASE WHEN buy_foreign_investor_tp_code IN ('10','30')  THEN execution_val ELSE 0 END) AS foreign_investor_total_buy_val,
        SUM(CASE WHEN sell_foreign_investor_tp_code IN ('10','30') THEN execution_val ELSE 0 END) AS foreign_investor_total_sell_val,
        SUM(CASE WHEN buy_foreign_investor_tp_code IN ('10','30')  AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_vol ELSE 0 END) AS foreign_investor_negotiated_buy_vol,
        SUM(CASE WHEN sell_foreign_investor_tp_code IN ('10','30') AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_vol ELSE 0 END) AS foreign_investor_negotiated_sell_vol,
        SUM(CASE WHEN buy_foreign_investor_tp_code IN ('10','30')  AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_val ELSE 0 END) AS foreign_investor_negotiated_buy_val,
        SUM(CASE WHEN sell_foreign_investor_tp_code IN ('10','30') AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_val ELSE 0 END) AS foreign_investor_negotiated_sell_val,
        SUM(CASE WHEN buy_foreign_investor_tp_code IN ('10','30')  AND board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN execution_vol ELSE 0 END) AS foreign_investor_matched_buy_vol,
        SUM(CASE WHEN sell_foreign_investor_tp_code IN ('10','30') AND board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN execution_vol ELSE 0 END) AS foreign_investor_matched_sell_vol,
        SUM(CASE WHEN buy_foreign_investor_tp_code IN ('10','30')  AND board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN execution_val ELSE 0 END) AS foreign_investor_matched_buy_val,
        SUM(CASE WHEN sell_foreign_investor_tp_code IN ('10','30') AND board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN execution_val ELSE 0 END) AS foreign_investor_matched_sell_val,
        SUM(CASE WHEN buy_client_house_cl_code = '30'  THEN execution_vol ELSE 0 END) AS proprietary_total_buy_vol,
        SUM(CASE WHEN sell_client_house_cl_code = '30' THEN execution_vol ELSE 0 END) AS proprietary_total_sell_vol,
        SUM(CASE WHEN buy_client_house_cl_code = '30'  THEN execution_val ELSE 0 END) AS proprietary_total_buy_val,
        SUM(CASE WHEN sell_client_house_cl_code = '30' THEN execution_val ELSE 0 END) AS proprietary_total_sell_val,
        SUM(CASE WHEN buy_client_house_cl_code = '30'  AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_vol ELSE 0 END) AS proprietary_negotiated_buy_vol,
        SUM(CASE WHEN sell_client_house_cl_code = '30' AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_vol ELSE 0 END) AS proprietary_negotiated_sell_vol,
        SUM(CASE WHEN buy_client_house_cl_code = '30'  AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_val ELSE 0 END) AS proprietary_negotiated_buy_val,
        SUM(CASE WHEN sell_client_house_cl_code = '30' AND board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_val ELSE 0 END) AS proprietary_negotiated_sell_val,
        SUM(CASE WHEN buy_client_house_cl_code = '30'  AND board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN execution_vol ELSE 0 END) AS proprietary_matched_buy_vol,
        SUM(CASE WHEN sell_client_house_cl_code = '30' AND board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN execution_vol ELSE 0 END) AS proprietary_matched_sell_vol,
        SUM(CASE WHEN buy_client_house_cl_code = '30'  AND board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN execution_val ELSE 0 END) AS proprietary_matched_buy_val,
        SUM(CASE WHEN sell_client_house_cl_code = '30' AND board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN execution_val ELSE 0 END) AS proprietary_matched_sell_val
    FROM trade_index
    GROUP BY
        trade_dt,
        index_code
),

market_index_ranked AS (
    SELECT
        market_code,
        trading_dt,
        market_index_val,
        ROW_NUMBER() OVER (
            PARTITION BY market_code
            ORDER BY index_time DESC) 
        AS rn
    FROM {{ ref('atm_market_index_snapshot') }}
    WHERE trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'MDDS_JAD_MARKETINFOR'
        AND market_code IN ('HOSE','HNX','UPCOM','30','HNX30','100')
),

market_index AS (
    SELECT
        market_code,
        trading_dt,
        market_index_val
    FROM market_index_ranked
    WHERE rn = 1
)

SELECT
    CAST(date_format(market_index.trading_dt, 'yyyyMMdd') AS string)             AS snpst_dt_dim_id,
    CAST(index_constituent_dim.index_constituent_dim_id AS string)               AS index_constituent_dim_id,
    CAST(market_index.market_index_val AS decimal(23,2))                         AS market_index_val,
    CAST(trade_summary.foreign_investor_total_buy_vol AS int)                    AS foreign_investor_total_buy_vol,
    CAST(trade_summary.foreign_investor_total_sell_vol AS int)                   AS foreign_investor_total_sell_vol,
    CAST(trade_summary.foreign_investor_total_buy_val AS decimal(23,2))          AS foreign_investor_total_buy_val,
    CAST(trade_summary.foreign_investor_total_sell_val AS decimal(23,2))         AS foreign_investor_total_sell_val,
    CAST(trade_summary.foreign_investor_negotiated_buy_vol AS int)               AS foreign_investor_negotiated_buy_vol,
    CAST(trade_summary.foreign_investor_negotiated_sell_vol AS int)              AS foreign_investor_negotiated_sell_vol,
    CAST(trade_summary.foreign_investor_negotiated_buy_val AS decimal(23,2))     AS foreign_investor_negotiated_buy_val,
    CAST(trade_summary.foreign_investor_negotiated_sell_val AS decimal(23,2))    AS foreign_investor_negotiated_sell_val,
    CAST(trade_summary.foreign_investor_matched_buy_vol AS int)                  AS foreign_investor_matched_buy_vol,
    CAST(trade_summary.foreign_investor_matched_sell_vol AS int)                 AS foreign_investor_matched_sell_vol,
    CAST(trade_summary.foreign_investor_matched_buy_val AS decimal(23,2))        AS foreign_investor_matched_buy_val,
    CAST(trade_summary.foreign_investor_matched_sell_val AS decimal(23,2))       AS foreign_investor_matched_sell_val,
    CAST(trade_summary.proprietary_total_buy_vol AS int)                         AS proprietary_total_buy_vol,
    CAST(trade_summary.proprietary_total_sell_vol AS int)                        AS proprietary_total_sell_vol,
    CAST(trade_summary.proprietary_total_buy_val AS decimal(23,2))               AS proprietary_total_buy_val,
    CAST(trade_summary.proprietary_total_sell_val AS decimal(23,2))              AS proprietary_total_sell_val,
    CAST(trade_summary.proprietary_negotiated_buy_vol AS int)                    AS proprietary_negotiated_buy_vol,
    CAST(trade_summary.proprietary_negotiated_sell_vol AS int)                   AS proprietary_negotiated_sell_vol,
    CAST(trade_summary.proprietary_negotiated_buy_val AS decimal(23,2))          AS proprietary_negotiated_buy_val,
    CAST(trade_summary.proprietary_negotiated_sell_val AS decimal(23,2))         AS proprietary_negotiated_sell_val,
    CAST(trade_summary.proprietary_matched_buy_vol AS int)                       AS proprietary_matched_buy_vol,
    CAST(trade_summary.proprietary_matched_sell_vol AS int)                      AS proprietary_matched_sell_vol,
    CAST(trade_summary.proprietary_matched_buy_val AS decimal(23,2))             AS proprietary_matched_buy_val,
    CAST(trade_summary.proprietary_matched_sell_val AS decimal(23,2))            AS proprietary_matched_sell_val,
    CAST('ORDERTRADE_TRADE_BOOK_HOSE_HNX' AS string)                             AS src_stm_code
FROM market_index
LEFT JOIN trade_summary
    ON trade_summary.index_code = market_index.market_code
JOIN index_constituent_dim
    ON index_constituent_dim.index_code = market_index.market_code

