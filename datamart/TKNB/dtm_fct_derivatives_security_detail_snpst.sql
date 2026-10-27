/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_derivatives_security_detail_snpst
* Program name: Fact Derivatives Security Detail Snapshot
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
* Ghi chu:
* - TKNB Nhom 29 - thay the Derivatives Security Detail Report BM043
*   (bm043mss_derivatives_security_detail_rpt, da bo khoi LLD). LLD
*   DTM_TKNB_fct_derivatives_security_detail_snpst.csv (commit 44b2f5e7,
*   2026-10-06). Grain: 1 dong / symbol HDTL / trading_dt.
* - Driving: atm_security_trading_snapshot loc floor_code = '03' va
*   trading_dt = etl_date (literal LLD). Dedup 1 dong/symbol theo
*   trading_time DESC giong dtm_security_trading_snpst_dim (GSTT) - tranh
*   nhan doi cac SUM khi atomic co nhieu ban ghi trong ngay.
* - security_trading_snpst_dim_id: lookup dtm_security_trading_snpst_dim
*   (model GSTT, dung chung) _hstr theo symbol. INNER JOIN vi cot NOT NULL
*   va dim cung nguon MDDS_JAD_STOCKINFOR.
* - atm_securities_trade: loc trade_dt = etl_date, market_id_code = 'DVX'.
*   Ghep ma theo security_symbol_code IN (symbol, isin_code) (literal LLD).
*   Cong don truoc theo security_symbol_code (trade_dvx) roi moi ghep vao
*   driving - tuong duong toan hoc voi LEFT JOIN + SUM tren tung lenh khop.
* - *_val = SUM(execution_vol * execution_price) * contract_multiplier:
*   contract_multiplier la hang so theo symbol (lay tu driving) nen dua
*   ra ngoai SUM - tuong duong literal LLD.
* - NDTNN: buy/sell_foreign_investor_tp_code IN ('10','20'); Tu doanh:
*   buy/sell_client_house_cl_code = '30' (literal LLD Nhom 29).
* - open_interest_quantity: atm_end_of_day_open_interest theo ticker_symbol
*   IN (symbol, isin_code), ds_snpst_dt = trading_dt, SUM (literal LLD).
* - snpst_dt_dim_id = date_format(trading_dt,'yyyyMMdd') theo convention,
*   khong JOIN vat ly dtm_cdr_dt_dim.
*--------------------------------------------------------------------*
*/

WITH se_tr_sn_all AS (
    SELECT
        symbol,
        isin_code,
        trading_dt,
        contract_multiplier,
        src_stm_code,
        ROW_NUMBER() OVER (
            PARTITION BY symbol
            ORDER BY trading_time DESC)
        AS rn
    FROM {{ ref('atm_security_trading_snapshot') }}
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND trading_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND src_stm_code = 'MDDS_JAD_STOCKINFOR'
        AND floor_code = '03'
),

se_tr_sn AS (
    SELECT
        symbol,
        isin_code,
        trading_dt,
        CAST(contract_multiplier AS decimal(23,4)) AS contract_multiplier,
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

trade_dvx AS (
    SELECT
        trade_dt,
        security_symbol_code,
        SUM(execution_vol)                                                                                   AS trading_vol,
        SUM(execution_vol * execution_price)                                                                 AS trading_amt,
        SUM(CASE WHEN buy_foreign_investor_tp_code IN ('10','20') THEN execution_vol ELSE 0 END)             AS foreign_investor_buy_vol,
        SUM(CASE WHEN sell_foreign_investor_tp_code IN ('10','20') THEN execution_vol ELSE 0 END)            AS foreign_investor_sell_vol,
        SUM(CASE WHEN buy_foreign_investor_tp_code IN ('10','20') THEN execution_vol * execution_price ELSE 0 END)  AS foreign_investor_buy_amt,
        SUM(CASE WHEN sell_foreign_investor_tp_code IN ('10','20') THEN execution_vol * execution_price ELSE 0 END) AS foreign_investor_sell_amt,
        SUM(CASE WHEN buy_client_house_cl_code = '30' THEN execution_vol ELSE 0 END)                         AS proprietary_buy_vol,
        SUM(CASE WHEN sell_client_house_cl_code = '30' THEN execution_vol ELSE 0 END)                        AS proprietary_sell_vol,
        SUM(CASE WHEN buy_client_house_cl_code = '30' THEN execution_vol * execution_price ELSE 0 END)       AS proprietary_buy_amt,
        SUM(CASE WHEN sell_client_house_cl_code = '30' THEN execution_vol * execution_price ELSE 0 END)      AS proprietary_sell_amt
    FROM {{ ref('atm_securities_trade') }}
    WHERE trade_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND market_id_code = 'DVX'
    GROUP BY
        trade_dt,
        security_symbol_code
),

trade_summary AS (
    SELECT
        se_tr_sn.symbol,
        SUM(trade_dvx.trading_vol)                AS trading_vol,
        SUM(trade_dvx.trading_amt)                AS trading_amt,
        SUM(trade_dvx.foreign_investor_buy_vol)   AS foreign_investor_buy_vol,
        SUM(trade_dvx.foreign_investor_sell_vol)  AS foreign_investor_sell_vol,
        SUM(trade_dvx.foreign_investor_buy_amt)   AS foreign_investor_buy_amt,
        SUM(trade_dvx.foreign_investor_sell_amt)  AS foreign_investor_sell_amt,
        SUM(trade_dvx.proprietary_buy_vol)        AS proprietary_buy_vol,
        SUM(trade_dvx.proprietary_sell_vol)       AS proprietary_sell_vol,
        SUM(trade_dvx.proprietary_buy_amt)        AS proprietary_buy_amt,
        SUM(trade_dvx.proprietary_sell_amt)       AS proprietary_sell_amt
    FROM se_tr_sn
    INNER JOIN trade_dvx
        ON trade_dvx.trade_dt = se_tr_sn.trading_dt
        AND trade_dvx.security_symbol_code IN (se_tr_sn.symbol, se_tr_sn.isin_code)
    GROUP BY
        se_tr_sn.symbol
),

open_interest AS (
    SELECT
        se_tr_sn.symbol,
        SUM(eo_oi.open_interest_quantity) AS open_interest_quantity
    FROM se_tr_sn
    INNER JOIN {{ ref('atm_end_of_day_open_interest') }} eo_oi
        ON eo_oi.ds_snpst_dt = se_tr_sn.trading_dt
        AND eo_oi.ticker_symbol IN (se_tr_sn.symbol, se_tr_sn.isin_code)
    WHERE eo_oi.ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND eo_oi.src_stm_code = 'VSDC_END_OF_DAY_OPEN_INTEREST'
    GROUP BY
        se_tr_sn.symbol
)

SELECT
    CAST(date_format(se_tr_sn.trading_dt, 'yyyyMMdd') AS string)                                     AS snpst_dt_dim_id,
    CAST(se_tr_sn_di.security_trading_snpst_dim_id AS string)                                       AS security_trading_snpst_dim_id,
    CAST(open_interest.open_interest_quantity AS bigint)                                            AS open_interest_quantity,
    CAST(trade_summary.trading_vol AS bigint)                                                       AS trading_vol,
    CAST(trade_summary.trading_amt * se_tr_sn.contract_multiplier AS decimal(23,2))                 AS trading_val,
    CAST(trade_summary.foreign_investor_buy_vol AS bigint)                                          AS foreign_investor_buy_vol,
    CAST(trade_summary.foreign_investor_sell_vol AS bigint)                                         AS foreign_investor_sell_vol,
    CAST(trade_summary.foreign_investor_buy_amt * se_tr_sn.contract_multiplier AS decimal(23,2))    AS foreign_investor_buy_val,
    CAST(trade_summary.foreign_investor_sell_amt * se_tr_sn.contract_multiplier AS decimal(23,2))   AS foreign_investor_sell_val,
    CAST(trade_summary.proprietary_buy_vol AS bigint)                                               AS proprietary_buy_vol,
    CAST(trade_summary.proprietary_sell_vol AS bigint)                                              AS proprietary_sell_vol,
    CAST(trade_summary.proprietary_buy_amt * se_tr_sn.contract_multiplier AS decimal(23,2))         AS proprietary_buy_val,
    CAST(trade_summary.proprietary_sell_amt * se_tr_sn.contract_multiplier AS decimal(23,2))        AS proprietary_sell_val,
    CAST(se_tr_sn.src_stm_code AS string)                                                           AS src_stm_code
FROM se_tr_sn
INNER JOIN se_tr_sn_di
    ON se_tr_sn_di.symbol = se_tr_sn.symbol
LEFT JOIN trade_summary
    ON trade_summary.symbol = se_tr_sn.symbol
LEFT JOIN open_interest
    ON open_interest.symbol = se_tr_sn.symbol
