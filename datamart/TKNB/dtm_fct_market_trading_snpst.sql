/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_market_trading_snpst
* Program name: Fact Market Trading Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Ghi chu:
* - Thay the Market Trading Report BM030a (DEPRECATED) - xem
*   DTM_TKNB_Entities.csv. Grain: 1 dong / trade_dt / index_code (6 ma:
*   HOSE, HNX, UPCOM, 30, HNX30, 100 - BA dong 1131/1132). Cac cot tong
*   giao dich (total/matched/negotiated/odd_lot) tinh THEO TUNG index_code
*   - JOIN securities_trade voi atm_index_constituent_snapshot theo symbol
*   (giong index_constituent/trade_index cua
*   dtm_fct_foreign_proprietary_trading_index_snpst.sql), GROUP BY
*   trade_dt, index_code. KHONG con la tong toan thi truong lap lai tren
*   6 dong nhu ban cu (sua 2026-09-24 theo yeu cau user - phat hien thieu
*   chieu index_code trong tinh toan).
* - atm_securities_trade: incremental_rebase/append, KHONG co _hstr, loc
*   truc tiep theo trade_dt.
* - Driving table cho grain moi la atm_market_index_snapshot (loc 6
*   market_code, dedup ban ghi cuoi ngay theo index_time) - dung theo
*   dung LLD source_entity/etl_logic cua index_constituent_dim_id va
*   market_index_val, KHONG phai atm_securities_trade.
* - index_constituent_dim_id: dim vat ly dtm_index_constituent_dim grain
*   that la (index_code, symbol) - 1 index_code co NHIEU dim_id. Dedup 1
*   dong/index_code bang ROW_NUMBER (order by symbol, chon dai dien bat
*   ky - khong anh huong y nghia), giong dung pattern da dung o
*   dtm_fct_market_index_snpst.sql (QLKD).
* - src_stm_code: LLD ghi "direct" tu securities_trade.src_stm_code, nhung
*   grain fact nay gop ca 2 gia tri nguon (ORDERTRADE_TRADE_BOOK_HOSE va
*   ORDERTRADE_TRADE_BOOK_HNX) trong cung 1 dong/ngay -> khong co 1 gia tri
*   don le dung. Dung literal gop 'ORDERTRADE_TRADE_BOOK_HOSE_HNX' theo
*   dung convention dat ten file da dung xuyen suot LLD TKNB (VD:
*   *_ORDERTRADE_TRADE_BOOK_HOSE_HNX.csv).
*--------------------------------------------------------------------*
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
        execution_val,
        execution_vol,
        board_tp_code
    FROM {{ ref('atm_securities_trade') }}
    WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
        AND market_id_code IN ('STK','STX','UPX')
),

trade_index AS (
    SELECT
        securities_trade.trade_dt,
        index_constituent.index_code,
        securities_trade.execution_val,
        securities_trade.execution_vol,
        securities_trade.board_tp_code
    FROM securities_trade
    INNER JOIN index_constituent
        ON index_constituent.symbol = securities_trade.security_symbol_code
),

trade_summary AS (
    SELECT
        trade_dt,
        index_code,
        SUM(execution_val) AS total_trading_val,
        SUM(execution_vol) AS total_trading_vol,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN execution_val ELSE 0 END) AS matched_trading_val,
        SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN execution_vol ELSE 0 END) AS matched_trading_vol,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_val ELSE 0 END) AS negotiated_trading_val,
        SUM(CASE WHEN board_tp_code IN ('T1','T2','T3','T4','T6','R1') THEN execution_vol ELSE 0 END) AS negotiated_trading_vol,
        SUM(CASE WHEN board_tp_code IN ('G4','T4','T6') THEN execution_val ELSE 0 END) AS odd_lot_trading_val,
        SUM(CASE WHEN board_tp_code IN ('G4','T4','T6') THEN execution_vol ELSE 0 END) AS odd_lot_trading_vol
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
        AND market_code IN ('HOSE','HNX','UPCOM','30','HNX30','100')
        AND src_stm_code = 'MDDS_JAD_MARKETINFOR'
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
    CAST(date_format(market_index.trading_dt, 'yyyyMMdd') AS string)     AS snpst_dt_dim_id,
    CAST(index_constituent_dim.index_constituent_dim_id AS string)       AS index_constituent_dim_id,
    CAST(market_index.market_index_val AS decimal(23,2))                 AS market_index_val,
    CAST(trade_summary.total_trading_val AS decimal(23,2))               AS total_trading_val,
    CAST(trade_summary.total_trading_vol AS int)                         AS total_trading_vol,
    CAST(trade_summary.matched_trading_val AS decimal(23,2))             AS matched_trading_val,
    CAST(trade_summary.matched_trading_vol AS int)                       AS matched_trading_vol,
    CAST(trade_summary.negotiated_trading_val AS decimal(23,2))          AS negotiated_trading_val,
    CAST(trade_summary.negotiated_trading_vol AS int)                    AS negotiated_trading_vol,
    CAST(trade_summary.odd_lot_trading_val AS decimal(23,2))             AS odd_lot_trading_val,
    CAST(trade_summary.odd_lot_trading_vol AS int)                       AS odd_lot_trading_vol,
    CAST('ORDERTRADE_TRADE_BOOK_HOSE_HNX' AS string)                     AS src_stm_code
FROM market_index
LEFT JOIN trade_summary
    ON trade_summary.index_code = market_index.market_code
LEFT JOIN index_constituent_dim
    ON index_constituent_dim.index_code = market_index.market_code
