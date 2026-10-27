-- [FIRST-TIME] ft_dtm_fct_market_risk_snpst: model khoi tao du lieu lich su (chay 1 lan khi go-live).
-- Ghi vao bang that cua model daily dtm_fct_market_risk_snpst (config ft_target='fct_market_risk_snpst', macro macros/first_time).
-- 2026-10-24 tuan.nguyenvanb: [BACKFILL-UAT-NEW] Ban FIRST-TIME cua dtm_fct_market_risk_snpst. Logic cot GIONG daily (gom ca sua K_PTTT_77/78 theo phien), khac o:
--   (1) bo moi loc ngay theo ngay-chay-daily / chan 50 ngay -> doc ca lich su atomic, ra 1 dong / ngay giao dich <= ngay-chay-daily;
--   (2) cac CTE 'chi ngay hien tai' tinh THEO NGAY: mkt_cap_today (dedupe ban tin cuoi ngay theo ma+ngay), tvi_num / tvi_den (GTGD co phieu va von hoa
--       free-float theo ngay; free_float VSDC as-of theo khoang hieu luc), total_margin_limit (VCSH CTCK: bao cao nop cung nam, sent_tms <= ngay);
--   (3) strategy append: SELECT tra them ds_snpst_dt = ngay giao dich (cuoi SELECT, khop vi tri cot bang that), thay cho snapshot gan ngay-chay-daily.
-- Chay SAU khi atomic nguon da nap lich su: atm_market_index_snapshot, atm_securities_trade, atm_security_trading_snapshot, atm_listed_share_information,
-- atm_cl_risk_indicator(_value), atm_sc_* (ft_atm_sc_report_input_value), atm_*_offering*. Chi ra dong cho ngay co phien chi so HOSE.

WITH -- [2026-10-24 TOI UU] ban tin cuoi ngay (index_time lon nhat) lay bang max_by + GROUP BY (hash aggregate, khong sort/shuffle theo window) - ket qua giong ROW_NUMBER ... ORDER BY index_time DESC = 1
mkt_idx_base AS (
    SELECT
        trading_dt
        , max_by(market_index_val, index_time) AS market_index_val
    FROM {{ ft_ref('ft_atm_market_index_snapshot') }}
    WHERE market_code = 'HOSE'   -- [BACKFILL-UAT-NEW] bo loc trading_dt <= ngay-chay-daily (nap ca lich su)
    GROUP BY trading_dt
),

mkt_idx_ret AS (
    SELECT
        mkt_idx_base.trading_dt
        , mkt_idx_base.market_index_val
        , LAG(mkt_idx_base.market_index_val) OVER (ORDER BY mkt_idx_base.trading_dt)                      AS prior_index_val
        , LN(mkt_idx_base.market_index_val
            / LAG(mkt_idx_base.market_index_val) OVER (ORDER BY mkt_idx_base.trading_dt))                   AS index_log_return
        , (mkt_idx_base.market_index_val - LAG(mkt_idx_base.market_index_val) OVER (ORDER BY mkt_idx_base.trading_dt))
            / LAG(mkt_idx_base.market_index_val) OVER (ORDER BY mkt_idx_base.trading_dt)                    AS vnindex_daily_return
    FROM mkt_idx_base
),

-- AVG(market_index_val) toan bo cac ngay trong thang chua ngay thong ke (khong dung ORDER BY -> aggregate ca partition)
mkt_idx_monthly AS (
    SELECT
        mkt_idx_ret.*
        , AVG(mkt_idx_ret.market_index_val) OVER (PARTITION BY trunc(mkt_idx_ret.trading_dt, 'MM'))        AS index_val_monthly_average
    FROM mkt_idx_ret
),

-- volatility_20_days (STDDEV_SAMP log-return 20 phien), R_bar_20 (vnindex_daily_return_average),
-- systemic_vol_current (STDDEV_SAMP return 20 phien x SQRT(252))
mkt_idx_vol AS (
    SELECT
        mkt_idx_monthly.*
        , STDDEV_SAMP(mkt_idx_monthly.index_log_return) OVER (
              ORDER BY mkt_idx_monthly.trading_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
          )                                                                                                AS volatility_20_days
        , AVG(mkt_idx_monthly.index_log_return) OVER (
              ORDER BY mkt_idx_monthly.trading_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
          )                                                                                                AS vnindex_daily_return_average
        , STDDEV_SAMP(mkt_idx_monthly.vnindex_daily_return) OVER (
              ORDER BY mkt_idx_monthly.trading_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
          ) * SQRT(252)                                                                                    AS systemic_vol_current
    FROM mkt_idx_monthly
),

-- z_score_volatility (cumulative z-score toan bo lich su <= snapshot_date), systemic_vol_max (MAX cumulative)
mkt_idx_z AS (
    SELECT
        mkt_idx_vol.*
        , (mkt_idx_vol.volatility_20_days
            - AVG(mkt_idx_vol.volatility_20_days) OVER (ORDER BY mkt_idx_vol.trading_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))
          / NULLIF(STDDEV_SAMP(mkt_idx_vol.volatility_20_days) OVER (ORDER BY mkt_idx_vol.trading_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 0)
                                                                                                             AS z_score_volatility
        , MAX(mkt_idx_vol.systemic_vol_current) OVER (ORDER BY mkt_idx_vol.trading_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
                                                                                                             AS systemic_vol_max
    FROM mkt_idx_vol
),

-- ===== atm_securities_trade: giao dich khop lenh co phieu (STK/STX/UPX, bang G1/G2/G3) =====
-- [2026-10-24 TOI UU] atm_securities_trade chi doc 1 LAN cho 3 nhom chi tieu (khop lenh G1-G8, dong tien rong NDTNN/tu doanh, GTGD co phieu 3 ky tu) bang
-- conditional aggregation; cung bo loc market_id_code. Gia tri tung nhom giong ban 3 CTE rieng (se_tr_matched_daily chi giu ngay co lenh thuoc bang G1..G8)
se_tr_agg AS (
    SELECT
        trade_dt
        , SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN execution_val END)   AS total_trading_val_matched
        , SUM(CASE WHEN board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN execution_vol END)   AS total_trading_vol_matched
        , COUNT(CASE WHEN board_tp_code IN ('G1','G2','G3','G4','G7','G8') THEN 1 END)             AS total_order_count_matched
        , SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('E','F') THEN execution_val ELSE 0 END)
            - SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('E','F') THEN execution_val ELSE 0 END)     AS foreign_net_flow
        , SUM(CASE WHEN SUBSTR(buy_account_nbr, 4, 1) IN ('A','E','P') THEN execution_val ELSE 0 END)
            - SUM(CASE WHEN SUBSTR(sell_account_nbr, 4, 1) IN ('A','E','P') THEN execution_val ELSE 0 END) AS proprietary_net_flow
        , SUM(CASE WHEN LENGTH(
                CASE
                    WHEN src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX'
                        THEN REGEXP_REPLACE(SUBSTR(security_symbol_code, 3, 9), '^0+', '')
                    ELSE security_symbol_code
                END
            ) = 3 THEN execution_val END)                                                          AS total_trading_val_stock
    FROM {{ ft_ref('ft_atm_securities_trade') }}
    WHERE market_id_code IN ('UPX','STX','STK','STO')   -- [BACKFILL-UAT-NEW] bo loc trade_dt <= ngay-chay-daily (nap ca lich su)
    GROUP BY trade_dt
),

se_tr_matched_daily AS (
    SELECT
        trade_dt
        , total_trading_val_matched
        , total_trading_vol_matched
        , total_order_count_matched
    FROM se_tr_agg
    WHERE total_order_count_matched > 0
),

matched_window AS (
    SELECT
        se_tr_matched_daily.*
        , LAG(se_tr_matched_daily.total_trading_val_matched) OVER (ORDER BY se_tr_matched_daily.trade_dt)  AS total_trading_val_matched_previous_day
        , AVG(se_tr_matched_daily.total_trading_val_matched) OVER (
              ORDER BY se_tr_matched_daily.trade_dt ROWS BETWEEN 49 PRECEDING AND CURRENT ROW
          )                                                                                                 AS total_trading_val_matched_average_50_days
        -- N=20 phien co dinh (LLD chot 2026-10-23, K_PTTT_124; truoc day N=30 hardcode)
        , AVG(se_tr_matched_daily.total_trading_val_matched) OVER (
              ORDER BY se_tr_matched_daily.trade_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
          )                                                                                                 AS total_trading_val_matched_average_n_days
    FROM se_tr_matched_daily
),

-- illiquidity_ratio & z_score_liquidity (khong loc board_tp_code rieng vi da dung lai
-- total_trading_val_matched da loc G1/G2/G3 o tren, dung theo dung mau so LLD)
illiq_daily AS (
    SELECT
        mkt_idx_z.trading_dt
        , ABS(mkt_idx_z.index_log_return) / NULLIF(matched_window.total_trading_val_matched, 0) AS illiquidity_ratio
    FROM mkt_idx_z
    LEFT JOIN matched_window
        ON matched_window.trade_dt = mkt_idx_z.trading_dt
),

illiq_z AS (
    SELECT
        illiq_daily.*
        , (illiq_daily.illiquidity_ratio
            - AVG(illiq_daily.illiquidity_ratio) OVER (ORDER BY illiq_daily.trading_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))
          / NULLIF(STDDEV_SAMP(illiq_daily.illiquidity_ratio) OVER (ORDER BY illiq_daily.trading_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 0)
                                                                                                             AS z_score_liquidity
    FROM illiq_daily
),

-- ===== Dong tien rong NDTNN / Tu doanh (theo so tai khoan: NDTNN E/F, Tu doanh A/E/P; KHONG loc board - LLD 05c7c2d3 O_PTTT_51) =====
se_tr_flows_daily AS (
    SELECT
        trade_dt
        , foreign_net_flow
        , proprietary_net_flow
    FROM se_tr_agg
),

se_tr_flows_window AS (
    SELECT
        se_tr_flows_daily.*
        , AVG(se_tr_flows_daily.foreign_net_flow) OVER (
              ORDER BY se_tr_flows_daily.trade_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
          )                                                                                                 AS net_flow_foreign_average_20_days
        , AVG(se_tr_flows_daily.proprietary_net_flow) OVER (
              ORDER BY se_tr_flows_daily.trade_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
          )                                                                                                 AS net_flow_proprietary_average_20_days
        , CORR(se_tr_flows_daily.foreign_net_flow, se_tr_flows_daily.proprietary_net_flow) OVER (
              ORDER BY se_tr_flows_daily.trade_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
          )                                                                                                 AS net_flow_correlation_foreign_proprietary
        -- [2026-10-23] 20 PHIEN gan nhat (theo BA: ROW_NUMBER ... rn <= 20), phuc vu z_score_foreign_net_flow (dao chieu dau).
        -- Ten cot *_all giu nguyen de khong doi tham chieu o SELECT cuoi; LLD ghi 'toan bo lich su' - cho design chot.
        , AVG(se_tr_flows_daily.foreign_net_flow) OVER (
              ORDER BY se_tr_flows_daily.trade_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
          )                                                                                                 AS foreign_net_flow_avg_all
        , STDDEV_SAMP(se_tr_flows_daily.foreign_net_flow) OVER (
              ORDER BY se_tr_flows_daily.trade_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
          )                                                                                                 AS foreign_net_flow_stddev_all
    FROM se_tr_flows_daily
),

-- ===== atm_cl_risk_indicator(_value): lai suat lien ngan hang (INTERBANK_IR) va DXY =====
-- Gia dinh code chua xac nhan bang du lieu that -> LEFT JOIN, tra NULL neu khong co (xem ghi chu dau file)
cl_ir_dxy_raw AS (
    SELECT
        v.period_dt
        , i.cl_risk_ind_code
        , v.val
    FROM {{ ref('atm_cl_risk_indicator_value') }} v
    INNER JOIN {{ ref('atm_cl_risk_indicator') }} i
        ON i.cl_risk_ind_id = v.cl_risk_ind_id
    WHERE i.cl_risk_ind_code IN ('INTERBANK_IR','DXY')   -- [BACKFILL-UAT-NEW] bo loc period_dt <= ngay-chay-daily
),

cl_ir_dxy_daily AS (
    SELECT
        period_dt
        , MAX(CASE WHEN cl_risk_ind_code = 'INTERBANK_IR' THEN val END) AS interbank_val
        , MAX(CASE WHEN cl_risk_ind_code = 'DXY' THEN val END)          AS dxy_val
    FROM cl_ir_dxy_raw
    GROUP BY period_dt
),

cl_ir_dxy_delta AS (
    SELECT
        cl_ir_dxy_daily.*
        , cl_ir_dxy_daily.interbank_val - LAG(cl_ir_dxy_daily.interbank_val) OVER (ORDER BY cl_ir_dxy_daily.period_dt) AS interbank_delta
        , LN(cl_ir_dxy_daily.dxy_val / NULLIF(LAG(cl_ir_dxy_daily.dxy_val) OVER (ORDER BY cl_ir_dxy_daily.period_dt), 0)) AS dxy_log_return
        , AVG(cl_ir_dxy_daily.interbank_val) OVER (ORDER BY cl_ir_dxy_daily.period_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS interbank_avg_all
        , STDDEV_SAMP(cl_ir_dxy_daily.interbank_val) OVER (ORDER BY cl_ir_dxy_daily.period_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS interbank_stddev_all
    FROM cl_ir_dxy_daily
),

-- [2026-10-24] delta lai suat / log-return DXY tinh tren CHUOI PHIEN chi so (LEFT JOIN vao phien truoc, LAG sau) - khop BA:
-- moi cap (index_log_return, delta) cung do tren 1 khoang phien. Truoc day LAG tren chuoi ngay lai suat (ke ca ngay khong co phien) -> lech khoang
ir_session AS (
    SELECT
        mkt_idx_z.trading_dt
        , mkt_idx_z.index_log_return
        , cl_ir_dxy_daily.interbank_val - LAG(cl_ir_dxy_daily.interbank_val) OVER (ORDER BY mkt_idx_z.trading_dt)               AS interbank_delta_session
        , LN(cl_ir_dxy_daily.dxy_val / NULLIF(LAG(cl_ir_dxy_daily.dxy_val) OVER (ORDER BY mkt_idx_z.trading_dt), 0))             AS dxy_log_return_session
    FROM mkt_idx_z
    LEFT JOIN cl_ir_dxy_daily
        ON cl_ir_dxy_daily.period_dt = mkt_idx_z.trading_dt
),

combined_idx_ir AS (
    -- [FIX 2026-09-29] index_log_return thuoc mkt_idx_z, KHONG PHAI illiq_z
    -- (illiq_z chi co trading_dt/illiquidity_ratio/z_score_liquidity) - loi
    -- UNRESOLVED_COLUMN khi build lan dau, da JOIN them mkt_idx_z de lay dung
    -- index_log_return.
    SELECT
        illiq_z.trading_dt
        , (cl_ir_dxy_delta.interbank_val - cl_ir_dxy_delta.interbank_avg_all)
            / NULLIF(cl_ir_dxy_delta.interbank_stddev_all, 0)                                              AS z_score_interbank_rate
        , CORR(ir_session.index_log_return, ir_session.interbank_delta_session) OVER (
              ORDER BY illiq_z.trading_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
          )                                                                                                 AS corr_index_interbank_rate
        , CORR(ir_session.index_log_return, ir_session.dxy_log_return_session) OVER (
              ORDER BY illiq_z.trading_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
          )                                                                                                 AS corr_index_dxy
    FROM illiq_z
    LEFT JOIN cl_ir_dxy_delta
        ON cl_ir_dxy_delta.period_dt = illiq_z.trading_dt
    LEFT JOIN ir_session
        ON ir_session.trading_dt = illiq_z.trading_dt
),

-- ===== Von hoa thi truong (MDDS, total_listing_vol) - chi can ngay hien tai =====
-- [2026-10-24] atomic giu MOI ban tin stockinfor trong ngay -> chi lay ban tin CUOI NGAY moi ma (trading_time, sequence) truoc khi cong, neu khong von hoa bi nhan theo so ban tin
-- [2026-10-24 TOI UU] ban tin cuoi ngay = max_by theo (trading_time, sequence) + GROUP BY (thay ROW_NUMBER ... = 1), ket qua giong nhau
mkt_cap_today_raw AS (
    SELECT
        ds_snpst_dt AS trading_dt
        , max_by(close_price, named_struct('t', trading_time, 's', sequence))       AS close_price
        , max_by(total_listing_vol, named_struct('t', trading_time, 's', sequence)) AS total_listing_vol
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}
    WHERE floor_code IN ('02','04','10')   -- [BACKFILL-UAT-NEW] bo loc ds_snpst_dt = ngay-chay-daily (moi ngay 1 dong von hoa)
        AND stock_tp_code = '2'
    GROUP BY ticker_symbol, ds_snpst_dt
),

mkt_cap_today AS (
    SELECT
        trading_dt
        , SUM(close_price * total_listing_vol) AS total_market_cap
    FROM mkt_cap_today_raw
    GROUP BY trading_dt
),

-- ===== Von hoa thi truong VSDC (outstanding_share_quantity) - can FULL LICH SU cho AVG 252 phien =====
-- [2026-10-24] dedupe ban tin cuoi ngay moi ma (truoc day cong MOI ban tin -> total_market_cap_vsdc ~1,7E+20 thay vi ~1E+16); chi doc 50 ngay lich
-- (LLD A19-R6) vi bo cot trung binh 252 phien, chuoi margin_to_cap chi can cua so 20 phien
-- [2026-10-24 TOI UU] max_by theo (trading_time, sequence) + GROUP BY thay ROW_NUMBER ... = 1
se_snpst_hist AS (
    SELECT
        ticker_symbol AS symbol
        , ds_snpst_dt AS trading_dt
        , max_by(close_price, named_struct('t', trading_time, 's', sequence)) AS close_price
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}
    WHERE floor_code IN ('02','04','10')   -- [BACKFILL-UAT-NEW] bo loc ds_snpst_dt <= ngay-chay-daily va chan duoi 50 ngay
        AND stock_tp_code = '2'
    GROUP BY ticker_symbol, ds_snpst_dt
),

lsi_hist AS (
    SELECT
        ticker_symbol AS symbol
        , ds_snpst_dt
        , outstanding_share_quantity
    FROM {{ ft_ref('ft_atm_listed_share_information') }}
    WHERE src_stm_code = 'VSDC_OUTSTANDING_SHARES'   -- [BACKFILL-UAT-NEW] bo loc ds_snpst_dt <= ngay-chay-daily
),

-- as-of range [valid_from_dt, valid_to_dt) - tuong duong subquery MAX(ds_snpst_dt<=trading_dt) trong LLD
lsi_ranges AS (
    SELECT
        symbol
        , ds_snpst_dt AS valid_from_dt
        , outstanding_share_quantity
        , LEAD(ds_snpst_dt) OVER (PARTITION BY symbol ORDER BY ds_snpst_dt) AS valid_to_dt
    FROM lsi_hist
),

se_snpst_with_shares AS (
    SELECT
        se_snpst_hist.trading_dt
        , se_snpst_hist.close_price
        , lsi_ranges.outstanding_share_quantity
    FROM se_snpst_hist
    LEFT JOIN lsi_ranges
        ON lsi_ranges.symbol = se_snpst_hist.symbol
        AND se_snpst_hist.trading_dt >= lsi_ranges.valid_from_dt
        AND (se_snpst_hist.trading_dt < lsi_ranges.valid_to_dt OR lsi_ranges.valid_to_dt IS NULL)
),

mkt_cap_vsdc_daily AS (
    SELECT
        trading_dt
        , SUM(close_price * outstanding_share_quantity) AS total_market_cap_vsdc
    FROM se_snpst_with_shares
    GROUP BY trading_dt
),

-- [2026-10-23] BO cot total_market_cap_vsdc_average_n_days (K_PTTT_116 tinh runtime tren BI theo :from_date-:to_date; TVI dung von hoa free-float 1 ngay)
mkt_cap_vsdc_window AS (
    SELECT
        mkt_cap_vsdc_daily.*
    FROM mkt_cap_vsdc_daily
),

-- ===== TVI 1 ngay (O_PTTT_48, BA dong 214, cap nhat 22/10): tu so = GTGD khop co phieu (ma 3 ky tu), KHONG loc board =====
-- HNX: security_symbol_code la ISIN (VN000000 + ma + so kiem tra) -> SUBSTR(3,9) bo '0' dau lay lai ma
tvi_num AS (
    SELECT
        trade_dt AS trading_dt
        , total_trading_val_stock
    FROM se_tr_agg   -- [BACKFILL-UAT-NEW] daily: 1 ngay; ft: moi ngay (se_tr_agg doc atm_securities_trade 1 lan)
),

-- mau so = von hoa dieu chinh free-float cua TUNG NGAY: ban tin cuoi ngay moi ma x free_float VSDC hieu luc tai ngay do
tvi_snpst AS (
    SELECT
        ticker_symbol AS symbol
        , ds_snpst_dt AS trading_dt
        , max_by(close_price, named_struct('t', trading_time, 's', sequence)) AS close_price
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}
    WHERE stock_tp_code = '2'   -- BA 22/10: loc co phieu (khong loc san 02/04/10); [BACKFILL-UAT-NEW] bo loc ds_snpst_dt = ngay-chay-daily
    GROUP BY ticker_symbol, ds_snpst_dt
),

-- [BACKFILL-UAT-NEW] as-of theo khoang hieu luc (daily: ban ghi VSDC moi nhat <= ngay-chay-daily) - dedupe 1 dong/ma/ds_snpst_dt truoc khi LEAD
tvi_ff_dedup AS (
    SELECT
        ticker_symbol AS symbol
        , ds_snpst_dt AS valid_from_dt
        , free_float_share_quantity
        , ROW_NUMBER() OVER (
            PARTITION BY ticker_symbol, ds_snpst_dt
            ORDER BY free_float_share_quantity DESC
        ) AS rn
    FROM {{ ft_ref('ft_atm_listed_share_information') }}
    WHERE src_stm_code = 'VSDC_OUTSTANDING_SHARES'
),

tvi_ff AS (
    SELECT
        symbol
        , valid_from_dt
        , free_float_share_quantity
        , LEAD(valid_from_dt) OVER (PARTITION BY symbol ORDER BY valid_from_dt) AS valid_to_dt
    FROM tvi_ff_dedup
    WHERE rn = 1
),

tvi_den AS (
    SELECT
        tvi_snpst.trading_dt
        , SUM(tvi_snpst.close_price * tvi_ff.free_float_share_quantity) AS total_market_cap_free_float
    FROM tvi_snpst
    LEFT JOIN tvi_ff
        ON tvi_ff.symbol = tvi_snpst.symbol
        AND tvi_snpst.trading_dt >= tvi_ff.valid_from_dt
        AND (tvi_snpst.trading_dt < tvi_ff.valid_to_dt OR tvi_ff.valid_to_dt IS NULL)
    GROUP BY tvi_snpst.trading_dt
),

-- =====================================================================
-- KHOI CTE MOI (2026-09-24) - noi 28 cot PENDING sang code that, xem GHI
-- CHU RIENG trong header cho chi tiet tung nhanh.
-- =====================================================================

-- ===== A. atm_risk_weight_config: beta_*/epsilon_error_term/weight_liquidity/
-- weight_stability - LOOKUP theo risk_factor_code (xem GHI CHU RIENG) =====
risk_wc AS (
    SELECT
        risk_factor_code
        , weight
    FROM {{ ref('atm_risk_weight_config') }}
    WHERE ds_rcrd_st = 'ACTIVE'
),

risk_wc_scalar AS (
    SELECT
        MAX(CASE WHEN risk_factor_code = 'VNINDEX_VOLATILITY' THEN weight END)      AS beta_volatility
        , MAX(CASE WHEN risk_factor_code = 'ILLIQ' THEN weight END)                 AS beta_liquidity
        , MAX(CASE WHEN risk_factor_code = 'MARGIN_BALANCE' THEN weight END)        AS beta_margin_balance
        , MAX(CASE WHEN risk_factor_code = 'INTERBANK_RATE' THEN weight END)        AS beta_interbank_rate
        , MAX(CASE WHEN risk_factor_code = 'FOREIGN_NET_FLOW' THEN weight END)      AS beta_foreign_net_flow
        , MAX(CASE WHEN risk_factor_code = 'EQUITY_CAPITAL_RAISING' THEN weight END) AS beta_equity_capital_raising
        , MAX(CASE WHEN risk_factor_code = 'RISK_INDEX' THEN weight END)            AS beta_intercept
        , MAX(CASE WHEN risk_factor_code = 'UNEXPLAINED_ERROR_TERM' THEN weight END) AS epsilon_error_term
        , MAX(CASE WHEN risk_factor_code = 'S_LIQUIDITY' THEN weight END)           AS weight_liquidity
        , MAX(CASE WHEN risk_factor_code = 'S_STABILITY' THEN weight END)           AS weight_stability
    FROM risk_wc
),

-- ===== B. atm_status_threshold_config: 5 nguong status - LOOKUP theo index_code =====
status_thr AS (
    SELECT
        index_code
        , from_value
        , to_value
        , status
    FROM {{ ref('atm_status_threshold_config') }}
    WHERE ds_rcrd_st = 'ACTIVE'
),

-- ===== C. equity_capital_raising_amt: UNION ALL 3 nguon, FULL LICH SU (cho
-- z_score_equity_capital_raising window 20 phien) =====
eq_cap_pc_daily AS (
    SELECT
        pc_res.official_letter_dt                          AS cap_dt
        , SUM(pc_res.total_collected_amt)                  AS amt
    FROM {{ ref('atm_pc_securities_offering_result') }} pc_res
    INNER JOIN {{ ref('atm_pc_securities_offering_plan') }} pc_plan
        ON pc_plan.pc_securities_offering_id = pc_res.pc_securities_offering_id
    WHERE pc_plan.offering_method_code IN ('1','2','3','5','9','11')   -- [BACKFILL-UAT-NEW] bo loc official_letter_dt <= ngay-chay-daily
    GROUP BY pc_res.official_letter_dt
),

eq_cap_sc_daily AS (
    SELECT
        sc_dis.document_dt                                 AS cap_dt
        , SUM(sc_dis.proceeds_collected_amt)                AS amt
    FROM {{ ref('atm_sc_disclosure_securities_offering') }} sc_dis
    WHERE sc_dis.offering_tp_code IN ('1','4','5','6','7')   -- [BACKFILL-UAT-NEW] bo loc document_dt <= ngay-chay-daily
    GROUP BY sc_dis.document_dt
),

-- [2026-10-21] KHOI PHUC nhanh fmc_securities_offering (design thiet ke lai entity, lld_FMS_OFFERING.yaml approved): atomic scd4a
-- atm_fmc_securities_offering, doc MAIN va chi lay ban ghi ACTIVE (ban ghi xoa o nguon ra INACTIVE). LLD: SUM(actual_total_val_amt)
-- GROUP BY approval_document_dt, khong loc loai chao ban.
eq_cap_fmc_daily AS (
    SELECT
        fmc.approval_document_dt                           AS cap_dt
        , SUM(fmc.actual_total_val_amt)                     AS amt
    FROM {{ ref('atm_fmc_securities_offering') }} fmc
    WHERE fmc.ds_rcrd_st = 'ACTIVE'   -- [BACKFILL-UAT-NEW] bo loc approval_document_dt <= ngay-chay-daily
    GROUP BY fmc.approval_document_dt
),
-- gan tung nguon vao dung lich giao dich thuc te (mkt_idx_z.trading_dt) de
-- window AVG/STDDEV tinh theo don vi PHIEN (khong phai ngay lich)
eq_cap_daily AS (
    SELECT
        mkt_idx_z.trading_dt
        , COALESCE(eq_cap_pc_daily.amt, 0) + COALESCE(eq_cap_sc_daily.amt, 0) + COALESCE(eq_cap_fmc_daily.amt, 0) AS equity_capital_raising_amt
    FROM mkt_idx_z
    LEFT JOIN eq_cap_pc_daily ON eq_cap_pc_daily.cap_dt = mkt_idx_z.trading_dt
    LEFT JOIN eq_cap_sc_daily ON eq_cap_sc_daily.cap_dt = mkt_idx_z.trading_dt
    LEFT JOIN eq_cap_fmc_daily ON eq_cap_fmc_daily.cap_dt = mkt_idx_z.trading_dt
),

eq_cap_window AS (
    SELECT
        eq_cap_daily.*
        , AVG(eq_cap_daily.equity_capital_raising_amt) OVER (
              ORDER BY eq_cap_daily.trading_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
          ) AS equity_capital_raising_amt_average_20_days
        , STDDEV_SAMP(eq_cap_daily.equity_capital_raising_amt) OVER (
              ORDER BY eq_cap_daily.trading_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
          ) AS equity_capital_raising_amt_stddev_20_days
    FROM eq_cap_daily
),

-- ===== D. Chain Margin thang (THANG): sc_periodic_report + sc_report_input_submission
-- (ref_id = sc_periodic_rpt_code, ref_tp_code = 'BAO_CAO_DINH_KY') + sc_report_input_value
-- (cell_id 'TS024' = du no margin - CANH BAO chua BA xac nhan, xem O_PTTT_15) =====
sc_periodic_rpt_month AS (
    SELECT
        spr.sc_id
        , spr.rpt_year
        , spr.period
        , spr.sent_tms
        , rpt_sub.sc_rpt_input_submission_id
        , rpt_sub.sc_rpt_input_submission_code
        , rpt_sub.sc_rpt_code AS form_code
    FROM {{ ref('atm_sc_periodic_report') }} spr
    INNER JOIN (
        -- [2026-10-24] bang submission append: nop lai = them 1 ban ghi CUNG id (data_dt = last_modified_at) -> chi lay ban ghi moi nhat (data_dt lon nhat) moi submission
        SELECT * FROM (
            SELECT s_v.*, ROW_NUMBER() OVER (PARTITION BY s_v.sc_rpt_input_submission_id ORDER BY s_v.data_dt DESC, s_v.ds_etl_pcs_tms DESC) AS rn_ver
            FROM {{ ref('atm_sc_report_input_submission') }} s_v
        ) s_r WHERE s_r.rn_ver = 1
    ) rpt_sub
        ON rpt_sub.ref_id = spr.sc_periodic_rpt_code
        AND rpt_sub.ref_tp_code = 'BAO_CAO_DINH_KY'
        -- [2026-10-24] bang atomic sc_report_input_submission tren UAT KHONG con scd2 (khong co ds_rcrd_st) -> bo loc ACTIVE
    -- [2026-10-24] chi lay form BCTHHD_CTCK (TS024 con o form BCTLAT, sheet khac) - xem safety_snpst
    INNER JOIN {{ ref('atm_sc_report') }} sc_rpt
        ON sc_rpt.sc_rpt_code = rpt_sub.sc_rpt_code
        AND sc_rpt.ds_rcrd_st = 'ACTIVE'
        AND sc_rpt.rpt_code = 'BCTHHD_CTCK'
    WHERE spr.ds_rcrd_st = 'ACTIVE'   -- [2026-10-19] scd2
        AND spr.rpt_period = 'THANG'
        AND spr.rpt_submission_status_code IN ('1','2')
),

-- dedup: 1 CTCK co the nop lai nhieu lan cung ky thang -> lay ban ghi nop
-- moi nhat theo sent_tms (tham khao pattern rn0/rn1 cua
-- dtm_opr_corporate_bond_issuer_credit_monitor.sql)
sc_periodic_rpt_month_ranked AS (
    SELECT
        sc_periodic_rpt_month.*
        , ROW_NUMBER() OVER (
            PARTITION BY sc_periodic_rpt_month.sc_id, sc_periodic_rpt_month.rpt_year, sc_periodic_rpt_month.period
            ORDER BY sc_periodic_rpt_month.sent_tms DESC
                , CAST(sc_periodic_rpt_month.sc_rpt_input_submission_code AS bigint) DESC
        ) AS rn0
    FROM sc_periodic_rpt_month
),

sc_periodic_rpt_month_latest AS (
    SELECT sc_id, rpt_year, period, sc_rpt_input_submission_id, form_code
    FROM sc_periodic_rpt_month_ranked
    WHERE rn0 = 1
),

-- [2026-10-24] sheet II.8 (Tinh hinh giao dich ky quy chung khoan) - DISTINCT vi deep_config co grain (config, sheet, cell)
margin_sheet AS (
    SELECT DISTINCT
        sc_rpt_code
        , sheet_id
    FROM {{ ref('atm_sc_report_deep_config') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND sheet_code = 'II.8'
),

-- Tong du no margin toan he thong CTCK theo tung ky thang (TS024)
margin_balance_monthly AS (
    SELECT
        sc_periodic_rpt_month_latest.rpt_year
        , sc_periodic_rpt_month_latest.period
        , SUM(CAST(rpt_val.cell_val AS decimal(23,2))) * 1000000 AS total_margin_balance   -- [2026-10-24 BA xac nhan] TS024 tinh theo TRIEU DONG -> x1.000.000 ra VND
    FROM sc_periodic_rpt_month_latest
    INNER JOIN {{ ft_ref('ft_atm_sc_report_input_value') }} rpt_val
        ON rpt_val.sc_rpt_input_submission_id = sc_periodic_rpt_month_latest.sc_rpt_input_submission_id
        AND rpt_val.cell_id = 'TS024'
        AND CAST(rpt_val.cell_val AS decimal(23,2)) IS NOT NULL
    INNER JOIN margin_sheet sh
        ON sh.sc_rpt_code = sc_periodic_rpt_month_latest.form_code
        AND sh.sheet_id = rpt_val.sheet_id
    GROUP BY sc_periodic_rpt_month_latest.rpt_year, sc_periodic_rpt_month_latest.period
),

-- margin_balance_delta = du no margin ky thang t - ky thang t-1
margin_balance_monthly_delta AS (
    SELECT
        margin_balance_monthly.*
        , margin_balance_monthly.total_margin_balance
            - LAG(margin_balance_monthly.total_margin_balance) OVER (
                  ORDER BY margin_balance_monthly.rpt_year, margin_balance_monthly.period
              )                                                                      AS margin_balance_delta
    FROM margin_balance_monthly
),

-- carry-forward (LLD O_PTTT_37): moi trading_dt lay ky bao cao THANG gan nhat
-- co du lieu TS024 va <= thang cua trading_dt (khong con yeu cau trung thang).
-- margin_balance_delta = delta cua chinh ky do so voi ky hop le truoc no (LAG o tren)
margin_period_for_day AS (
    SELECT
        mkt_cap_vsdc_daily.trading_dt
        , mbmd.total_margin_balance
        , mbmd.margin_balance_delta
        , ROW_NUMBER() OVER (
            PARTITION BY mkt_cap_vsdc_daily.trading_dt
            ORDER BY mbmd.rpt_year DESC, mbmd.period DESC
        ) AS rn_period
    FROM mkt_cap_vsdc_daily
    INNER JOIN margin_balance_monthly_delta mbmd
        ON (mbmd.rpt_year * 100 + mbmd.period)
            <= (YEAR(mkt_cap_vsdc_daily.trading_dt) * 100 + MONTH(mkt_cap_vsdc_daily.trading_dt))
),

-- gan gia tri ky gan nhat cho tung trading_dt (full lich su) de tinh
-- margin_to_cap_ratio_current/avg/stddev tren 30 PHIEN GIAO DICH
margin_ratio_daily AS (
    SELECT
        mkt_cap_vsdc_daily.trading_dt
        , mpfd.total_margin_balance
        , mpfd.margin_balance_delta
        , mpfd.total_margin_balance / NULLIF(mkt_cap_vsdc_daily.total_market_cap_vsdc, 0) * 100 AS margin_to_cap_ratio_current
    FROM mkt_cap_vsdc_daily
    LEFT JOIN margin_period_for_day mpfd
        ON mpfd.trading_dt = mkt_cap_vsdc_daily.trading_dt
        AND mpfd.rn_period = 1
),

margin_ratio_window AS (
    SELECT
        margin_ratio_daily.*
        , AVG(margin_ratio_daily.margin_to_cap_ratio_current) OVER (
              ORDER BY margin_ratio_daily.trading_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
          ) AS margin_to_cap_ratio_avg
        , STDDEV_SAMP(margin_ratio_daily.margin_to_cap_ratio_current) OVER (
              ORDER BY margin_ratio_daily.trading_dt ROWS BETWEEN 19 PRECEDING AND CURRENT ROW
          ) AS margin_to_cap_ratio_stddev
    FROM margin_ratio_daily
),

-- ===== E. total_margin_limit_amt = 2 x SUM(VCSH CTCK), 1 bao cao/CTCK uu
-- tien Nam > Ban nien > Quy, cell TS359 (BCTCHN) hoac fallback TS223/TS221
-- (BCTCRL) - CANH BAO gia dinh ve phan biet BCTCHN/BCTCRL, xem GHI CHU RIENG =====
-- [BACKFILL-UAT-NEW] daily: 1 gia tri cho ngay-chay-daily (bao cao nop trong NAM cua ngay-chay-daily, sent_tms <= ngay-chay-daily). First-time: tinh lai cho TUNG ngay
-- giao dich (cung quy tac) bang cach ghep ngay voi cac bao cao nop cung nam, da nop <= ngay do
sc_periodic_rpt_year_base AS (
    SELECT
        spr.sc_id
        , spr.rpt_period
        , spr.sent_tms
        , CAST(spr.sent_tms AS date) AS sent_dt
        , rpt_sub.sc_rpt_input_submission_id
    FROM {{ ref('atm_sc_periodic_report') }} spr
    INNER JOIN (
        -- [2026-10-24] bang submission append: nop lai = them 1 ban ghi CUNG id (data_dt = last_modified_at) -> chi lay ban ghi moi nhat (data_dt lon nhat) moi submission
        SELECT * FROM (
            SELECT s_v.*, ROW_NUMBER() OVER (PARTITION BY s_v.sc_rpt_input_submission_id ORDER BY s_v.data_dt DESC, s_v.ds_etl_pcs_tms DESC) AS rn_ver
            FROM {{ ref('atm_sc_report_input_submission') }} s_v
        ) s_r WHERE s_r.rn_ver = 1
    ) rpt_sub
        ON rpt_sub.ref_id = spr.sc_periodic_rpt_code
        AND rpt_sub.ref_tp_code = 'BAO_CAO_DINH_KY'
        -- [2026-10-24] bang atomic sc_report_input_submission tren UAT KHONG con scd2 (khong co ds_rcrd_st) -> bo loc ACTIVE
    WHERE spr.ds_rcrd_st = 'ACTIVE'
        AND spr.rpt_period IN ('NAM','BAN_NIEN','QUY')
        AND spr.rpt_submission_status_code IN ('1','2')
),

mkt_days AS (
    SELECT DISTINCT trading_dt FROM mkt_idx_z
),

sc_periodic_rpt_year AS (
    SELECT
        mkt_days.trading_dt
        , b.sc_id
        , b.rpt_period
        , b.sent_tms
        , b.sc_rpt_input_submission_id
    FROM mkt_days
    INNER JOIN sc_periodic_rpt_year_base b
        ON YEAR(b.sent_dt) = YEAR(mkt_days.trading_dt)
        AND b.sent_dt <= mkt_days.trading_dt
),

sc_periodic_rpt_year_ranked AS (
    SELECT
        sc_periodic_rpt_year.*
        , ROW_NUMBER() OVER (
            PARTITION BY sc_periodic_rpt_year.trading_dt, sc_periodic_rpt_year.sc_id
            ORDER BY
                CASE sc_periodic_rpt_year.rpt_period
                    WHEN 'NAM' THEN 1
                    WHEN 'BAN_NIEN' THEN 2
                    WHEN 'QUY' THEN 3
                END
                , sc_periodic_rpt_year.sent_tms DESC
        ) AS rn0
    FROM sc_periodic_rpt_year
),

sc_periodic_rpt_year_latest AS (
    SELECT trading_dt, sc_id, sc_rpt_input_submission_id
    FROM sc_periodic_rpt_year_ranked
    WHERE rn0 = 1
),

vcsh_ctck AS (
    SELECT
        sc_periodic_rpt_year_latest.trading_dt
        , sc_periodic_rpt_year_latest.sc_id
        , COALESCE(
              MAX(CASE WHEN rpt_val.cell_id = 'TS359' THEN CAST(rpt_val.cell_val AS decimal(23,2)) END)
            , NULLIF(MAX(CASE WHEN rpt_val.cell_id = 'TS223' THEN CAST(rpt_val.cell_val AS decimal(23,2)) END), 0)
            , MAX(CASE WHEN rpt_val.cell_id = 'TS221' THEN CAST(rpt_val.cell_val AS decimal(23,2)) END)
          ) AS vcsh_amt
    FROM sc_periodic_rpt_year_latest
    INNER JOIN {{ ft_ref('ft_atm_sc_report_input_value') }} rpt_val
        ON rpt_val.sc_rpt_input_submission_id = sc_periodic_rpt_year_latest.sc_rpt_input_submission_id
        AND rpt_val.cell_id IN ('TS359','TS223','TS221')
    GROUP BY sc_periodic_rpt_year_latest.trading_dt, sc_periodic_rpt_year_latest.sc_id
),

total_margin_limit AS (
    SELECT
        vcsh_ctck.trading_dt
        , 2 * SUM(vcsh_ctck.vcsh_amt) AS total_margin_limit_amt
    FROM vcsh_ctck
    GROUP BY vcsh_ctck.trading_dt
),

-- ===== F. sentiment_index: weighted-average theo GTGD tung ma CK (xem GHI
-- CHU RIENG cho cong thuc day du) =====
-- [2026-10-09 LLD] ban ghi trading_time moi nhat moi ma/ngay; KL khop Vt va MAvol(20)
-- lay tu snapshot.total_trading_vol (khop cong don), BO nguon securities_trade
-- [2026-10-24 TOI UU] max_by theo (trading_time, sequence) + GROUP BY thay ROW_NUMBER ... = 1 (bang tick toan lich su: tranh sort/shuffle theo window)
se_snpst_sentiment_hist AS (
    SELECT
        ticker_symbol AS symbol
        , ds_snpst_dt AS trading_dt
        , max_by(open_price, named_struct('t', trading_time, 's', sequence))         AS open_price
        , max_by(close_price, named_struct('t', trading_time, 's', sequence))        AS close_price
        , max_by(total_trading_val, named_struct('t', trading_time, 's', sequence))  AS total_trading_val
        , max_by(total_trading_vol, named_struct('t', trading_time, 's', sequence))  AS total_trading_vol
    FROM {{ ft_ref('ft_atm_security_trading_snapshot') }}
    WHERE floor_code IN ('02','04','10')   -- [BACKFILL-UAT-NEW] bo loc ds_snpst_dt <= ngay-chay-daily
        AND stock_tp_code IN ('2','3')
    GROUP BY ticker_symbol, ds_snpst_dt
),

se_snpst_sentiment_lag AS (
    SELECT
        se_snpst_sentiment_hist.*
        , LAG(se_snpst_sentiment_hist.close_price) OVER (
              PARTITION BY se_snpst_sentiment_hist.symbol ORDER BY se_snpst_sentiment_hist.trading_dt
          ) AS close_price_previous_day
        , AVG(se_snpst_sentiment_hist.total_trading_vol) OVER (
              PARTITION BY se_snpst_sentiment_hist.symbol
              ORDER BY se_snpst_sentiment_hist.trading_dt ROWS BETWEEN 20 PRECEDING AND 1 PRECEDING
          ) AS total_trading_vol_average_20_days_prior
    FROM se_snpst_sentiment_hist
),

sentiment_score_daily AS (
    SELECT
        se_snpst_sentiment_lag.symbol
        , se_snpst_sentiment_lag.trading_dt
        , se_snpst_sentiment_lag.total_trading_val
        , 50 + SIGN(se_snpst_sentiment_lag.close_price - se_snpst_sentiment_lag.open_price)
            * LEAST(
                (se_snpst_sentiment_lag.total_trading_vol / NULLIF(se_snpst_sentiment_lag.total_trading_vol_average_20_days_prior, 0)) * 25
                , 50
              )                                                                       AS s_liquidity
        , GREATEST(
              0
              , 100 - ABS(LN(se_snpst_sentiment_lag.close_price / NULLIF(se_snpst_sentiment_lag.close_price_previous_day, 0))) * 50
          )                                                                            AS s_stability
    FROM se_snpst_sentiment_lag
),

sentiment_index_daily AS (
    SELECT
        sentiment_score_daily.trading_dt
        , SUM(
              (risk_wc_scalar.weight_liquidity * sentiment_score_daily.s_liquidity
                  + risk_wc_scalar.weight_stability * sentiment_score_daily.s_stability)
              * sentiment_score_daily.total_trading_val
          ) / NULLIF(SUM(sentiment_score_daily.total_trading_val), 0)                  AS sentiment_index
    FROM sentiment_score_daily
    CROSS JOIN risk_wc_scalar
    GROUP BY sentiment_score_daily.trading_dt
)

SELECT
    CAST(date_format(mkt_idx_z.trading_dt, 'yyyyMMdd') AS string)                              AS snpst_dt_dim_id,
    CAST(mkt_idx_z.volatility_20_days AS decimal(38,20))                                         AS volatility_20_days,
    CAST(mkt_idx_z.z_score_volatility AS decimal(5,2))                                         AS z_score_volatility,
    CAST(illiq_z.z_score_liquidity AS decimal(5,2))                                            AS z_score_liquidity,
    CAST(
        (margin_ratio_window.margin_to_cap_ratio_current - margin_ratio_window.margin_to_cap_ratio_avg)
        / NULLIF(margin_ratio_window.margin_to_cap_ratio_stddev, 0)
    AS decimal(5,2))                                                                            AS z_score_margin_balance, -- TINH DUOC (2026-09-24): noi day chuyen tu margin_to_cap_ratio_current/avg/stddev (chain sc_periodic_report/sc_report_input_submission/value, cell_id TS024 - CANH BAO cell_id chua BA xac nhan, xem O_PTTT_15)
    CAST(combined_idx_ir.z_score_interbank_rate AS decimal(5,2))                               AS z_score_interbank_rate,
    CAST(
        (se_tr_flows_window.foreign_net_flow_avg_all - se_tr_flows_window.foreign_net_flow)
        / NULLIF(se_tr_flows_window.foreign_net_flow_stddev_all, 0)
    AS decimal(5,2))                                                                            AS z_score_foreign_net_flow,
    CAST(mkt_cap_today.total_market_cap AS decimal(23,2))                                      AS total_market_cap,
    CAST(risk_wc_scalar.beta_volatility AS decimal(38,20))                                       AS beta_volatility, -- TINH DUOC (2026-09-24): risk_weight_config.weight WHERE risk_factor_code='VNINDEX_VOLATILITY' (xem GHI CHU RIENG ve risk_factor_group)
    CAST(risk_wc_scalar.beta_liquidity AS decimal(38,20))                                        AS beta_liquidity, -- TINH DUOC: risk_factor_code='ILLIQ'
    CAST(risk_wc_scalar.beta_margin_balance AS decimal(38,20))                                   AS beta_margin_balance, -- TINH DUOC: risk_factor_code='MARGIN_BALANCE'
    CAST(risk_wc_scalar.beta_interbank_rate AS decimal(38,20))                                   AS beta_interbank_rate, -- TINH DUOC: risk_factor_code='INTERBANK_RATE'
    CAST(risk_wc_scalar.beta_foreign_net_flow AS decimal(38,20))                                 AS beta_foreign_net_flow, -- TINH DUOC: risk_factor_code='FOREIGN_NET_FLOW'
    CAST(risk_wc_scalar.beta_equity_capital_raising AS decimal(38,20))                           AS beta_equity_capital_raising, -- TINH DUOC: risk_factor_code='EQUITY_CAPITAL_RAISING'
    CAST(risk_wc_scalar.beta_intercept AS decimal(38,20))                                        AS beta_intercept, -- TINH DUOC: risk_factor_code='RISK_INDEX'
    CAST(
        risk_wc_scalar.beta_intercept
        + risk_wc_scalar.beta_liquidity * illiq_z.z_score_liquidity
        + risk_wc_scalar.beta_volatility * mkt_idx_z.z_score_volatility
        + risk_wc_scalar.beta_margin_balance * (
              (margin_ratio_window.margin_to_cap_ratio_current - margin_ratio_window.margin_to_cap_ratio_avg)
              / NULLIF(margin_ratio_window.margin_to_cap_ratio_stddev, 0)
          )
        + risk_wc_scalar.beta_interbank_rate * combined_idx_ir.z_score_interbank_rate
        + risk_wc_scalar.beta_foreign_net_flow * (
              (se_tr_flows_window.foreign_net_flow_avg_all - se_tr_flows_window.foreign_net_flow)
              / NULLIF(se_tr_flows_window.foreign_net_flow_stddev_all, 0)
          )
        + risk_wc_scalar.beta_equity_capital_raising * (
              (eq_cap_window.equity_capital_raising_amt_average_20_days - eq_cap_window.equity_capital_raising_amt)
              / NULLIF(eq_cap_window.equity_capital_raising_amt_stddev_20_days, 0)
          )
        + risk_wc_scalar.epsilon_error_term
    AS decimal(5,2))                                                                            AS risk_index, -- TINH DUOC (2026-09-24): tong hop toan bo beta_*/z_score_*/epsilon_error_term theo dung cong thuc LLD
    CAST(risk_wc_scalar.epsilon_error_term AS decimal(38,20))                                    AS epsilon_error_term, -- TINH DUOC: risk_factor_code='UNEXPLAINED_ERROR_TERM'
    CAST(
        (eq_cap_window.equity_capital_raising_amt_average_20_days - eq_cap_window.equity_capital_raising_amt)
        / NULLIF(eq_cap_window.equity_capital_raising_amt_stddev_20_days, 0)
    AS decimal(5,2))                                                                            AS z_score_equity_capital_raising, -- TINH DUOC (2026-09-24): Z-score dao chieu, window 20 phien tren equity_capital_raising_amt
    CAST(eq_cap_window.equity_capital_raising_amt AS decimal(23,2))                            AS equity_capital_raising_amt, -- TINH DUOC (2026-09-24): UNION ALL 3 nguon (pc_securities_offering_result+plan / sc_disclosure_securities_offering / fmc_securities_offering), xem GHI CHU RIENG
    CAST(margin_ratio_window.margin_to_cap_ratio_stddev AS decimal(5,2))                       AS margin_to_cap_ratio_stddev, -- TINH DUOC (2026-09-24): STDDEV_SAMP 30 phien tren margin_to_cap_ratio_current
    CAST(margin_ratio_window.margin_to_cap_ratio_current AS decimal(5,2))                      AS margin_to_cap_ratio_current, -- TINH DUOC (2026-09-24): total_margin_balance / total_market_cap_vsdc * 100 (cell_id TS024 - CANH BAO chua BA xac nhan, xem O_PTTT_15)
    CAST(margin_ratio_window.margin_to_cap_ratio_avg AS decimal(5,2))                          AS margin_to_cap_ratio_avg, -- TINH DUOC (2026-09-24): AVG 30 phien tren margin_to_cap_ratio_current
    CAST(margin_ratio_window.total_margin_balance AS decimal(23,2))                            AS total_margin_balance, -- TINH DUOC (2026-09-24): SUM(TO_NUMBER(item_val)) WHERE cell_id='TS024', dedup theo sent_tms cua ky bao cao thang (BAO_CAO_DINH_KY) - CANH BAO cell_id chua BA xac nhan, xem O_PTTT_15
    CAST(mkt_idx_z.index_log_return AS decimal(38,20))                                           AS index_log_return,
    CAST(illiq_z.illiquidity_ratio AS decimal(38,20))                                            AS illiquidity_ratio,
    CAST(se_tr_flows_window.foreign_net_flow AS decimal(23,2))                                 AS foreign_net_flow,
    CAST(mkt_idx_z.market_index_val AS decimal(23,2))                                          AS vnindex_val,
    CAST(risk_wc_scalar.weight_liquidity AS decimal(38,20))                                      AS weight_liquidity, -- TINH DUOC (2026-09-24): risk_factor_code='S_LIQUIDITY'
    CAST(risk_wc_scalar.weight_stability AS decimal(38,20))                                      AS weight_stability, -- TINH DUOC (2026-09-24): risk_factor_code='S_STABILITY'
    CAST(sentiment_index_daily.sentiment_index AS decimal(5,2))                                AS sentiment_index, -- TINH DUOC (2026-09-24): weighted-average theo GTGD tung ma CK (weight_liquidity/weight_stability nay da co), xem GHI CHU RIENG
    CAST(thr_sentiment.status AS string)                                                       AS sentiment_index_status, -- TINH DUOC (2026-09-24): LOOKUP status_threshold_config index_code='SENTIMENTINDEX'
    CAST(
        margin_ratio_window.total_margin_balance / NULLIF(total_margin_limit.total_margin_limit_amt, 0) * 100
    AS decimal(5,2))                                                                            AS margin_tension, -- TINH DUOC (2026-09-24): total_margin_balance / total_margin_limit_amt * 100
    CAST(thr_margin_tension.status AS string)                                                  AS margin_tension_status, -- TINH DUOC (2026-09-24): LOOKUP status_threshold_config index_code='MARGINTENSION'
    CAST(mkt_idx_z.vnindex_daily_return AS decimal(38,20))                                       AS vnindex_daily_return,
    CAST(mkt_idx_z.systemic_vol_current AS decimal(38,20))                                       AS systemic_vol_current,
    CAST(mkt_idx_z.systemic_vol_max AS decimal(38,20))                                           AS systemic_vol_max,
    CAST(mkt_idx_z.systemic_vol_current / NULLIF(mkt_idx_z.systemic_vol_max, 0) * 100 AS decimal(5,2)) AS systemic_vol,
    CAST(thr_systemic_vol.status AS string)                                                    AS systemic_vol_status, -- TINH DUOC (2026-09-24): LOOKUP status_threshold_config index_code='SYSTEMICVOL'
    CAST(mkt_idx_z.prior_index_val AS decimal(23,2))                                           AS vnindex_val_previous_day,
    CAST(mkt_idx_z.vnindex_daily_return_average AS decimal(38,20))                               AS vnindex_daily_return_average,
    CAST(mkt_idx_z.index_val_monthly_average AS decimal(23,2))                                 AS index_val_monthly_average,
    CAST(matched_window.total_trading_val_matched AS decimal(23,2))                            AS total_trading_val_matched,
    CAST(matched_window.total_trading_val_matched_previous_day AS decimal(23,2))                AS total_trading_val_matched_previous_day,
    CAST(matched_window.total_order_count_matched AS int)                                      AS total_order_count_matched,
    CAST(matched_window.total_trading_val_matched / NULLIF(matched_window.total_order_count_matched, 0) AS decimal(23,2)) AS average_order_size,
    CAST(matched_window.total_trading_vol_matched AS decimal(23,2))                            AS total_trading_vol_matched,
    CAST(matched_window.total_trading_val_matched_average_50_days AS decimal(23,2))            AS total_trading_val_matched_average_50_days,
    -- N=30 hardcode (tham so cau hinh chua ton tai, xem ghi chu dau file)
    CAST(matched_window.total_trading_val_matched_average_n_days AS decimal(23,2))             AS total_trading_val_matched_average_n_days,
    CAST(se_tr_flows_window.net_flow_foreign_average_20_days AS decimal(23,2))                 AS net_flow_foreign_average_20_days,
    CAST(se_tr_flows_window.net_flow_proprietary_average_20_days AS decimal(23,2))              AS net_flow_proprietary_average_20_days,
    CAST(se_tr_flows_window.net_flow_correlation_foreign_proprietary AS decimal(5,2))           AS net_flow_correlation_foreign_proprietary,
    CAST(total_margin_limit.total_margin_limit_amt AS decimal(23,2))                           AS total_margin_limit_amt, -- TINH DUOC (2026-09-24): 2*SUM(VCSH CTCK) uu tien Nam>Ban nien>Quy, cell TS359/TS223/TS221 - CANH BAO gia dinh BCTCHN/BCTCRL, xem GHI CHU RIENG
    CAST(
        ABS(margin_ratio_window.margin_balance_delta) / NULLIF(matched_window.total_trading_val_matched_average_n_days, 0) * 100
    AS decimal(5,2))                                                                            AS margin_stress, -- TINH DUOC (2026-09-24): ABS(margin_balance_delta) / total_trading_val_matched_average_n_days * 100
    CAST(thr_margin_stress.status AS string)                                                   AS margin_stress_status, -- TINH DUOC (2026-09-24): LOOKUP status_threshold_config index_code='MARGINSTRESS'
    CAST(margin_ratio_window.margin_balance_delta AS decimal(23,2))                            AS margin_balance_delta, -- TINH DUOC (2026-09-24): delta du no margin ky thang t vs t-1 (cell_id TS024 - CANH BAO chua BA xac nhan, xem O_PTTT_15)
    CAST(combined_idx_ir.corr_index_interbank_rate AS decimal(5,4))                            AS corr_index_interbank_rate,
    CAST(combined_idx_ir.corr_index_dxy AS decimal(5,4))                                       AS corr_index_dxy,
    CAST(mkt_cap_vsdc_window.total_market_cap_vsdc AS decimal(23,2))                           AS total_market_cap_vsdc,
    CAST(
        tvi_num.total_trading_val_stock
        / NULLIF(tvi_den.total_market_cap_free_float, 0) * 100
    AS decimal(18,10))                                                                          AS turnover_velocity_index, -- O_PTTT_48 (2026-10-23): 1 ngay, free-float, x100 (%), khong * 252
    CAST(thr_turnover_velocity.status AS string)                                               AS turnover_velocity_status, -- TINH DUOC (2026-09-24): LOOKUP status_threshold_config index_code='TVI'
    CAST(mkt_idx_z.trading_dt AS date)                                                         AS ds_snpst_dt   -- [BACKFILL-UAT-NEW] = ngay giao dich (daily: = ngay-chay-daily, do strategy snapshot tu them)
FROM mkt_idx_z
LEFT JOIN illiq_z
    ON illiq_z.trading_dt = mkt_idx_z.trading_dt
LEFT JOIN se_tr_flows_window
    ON se_tr_flows_window.trade_dt = mkt_idx_z.trading_dt
LEFT JOIN combined_idx_ir
    ON combined_idx_ir.trading_dt = mkt_idx_z.trading_dt
LEFT JOIN matched_window
    ON matched_window.trade_dt = mkt_idx_z.trading_dt
CROSS JOIN risk_wc_scalar
LEFT JOIN eq_cap_window
    ON eq_cap_window.trading_dt = mkt_idx_z.trading_dt
LEFT JOIN margin_ratio_window
    ON margin_ratio_window.trading_dt = mkt_idx_z.trading_dt
LEFT JOIN total_margin_limit
    ON total_margin_limit.trading_dt = mkt_idx_z.trading_dt   -- [BACKFILL-UAT-NEW] daily: CROSS JOIN (1 gia tri cho ngay-chay-daily)
LEFT JOIN sentiment_index_daily
    ON sentiment_index_daily.trading_dt = mkt_idx_z.trading_dt
LEFT JOIN status_thr thr_sentiment
    ON thr_sentiment.index_code = 'SENTIMENTINDEX'
    AND sentiment_index_daily.sentiment_index BETWEEN thr_sentiment.from_value AND thr_sentiment.to_value
LEFT JOIN status_thr thr_margin_tension
    ON thr_margin_tension.index_code = 'MARGINTENSION'
    AND (margin_ratio_window.total_margin_balance / NULLIF(total_margin_limit.total_margin_limit_amt, 0) * 100)
        BETWEEN thr_margin_tension.from_value AND thr_margin_tension.to_value
LEFT JOIN status_thr thr_margin_stress
    ON thr_margin_stress.index_code = 'MARGINSTRESS'
    AND (ABS(margin_ratio_window.margin_balance_delta) / NULLIF(matched_window.total_trading_val_matched_average_n_days, 0) * 100)
        BETWEEN thr_margin_stress.from_value AND thr_margin_stress.to_value
LEFT JOIN status_thr thr_systemic_vol
    ON thr_systemic_vol.index_code = 'SYSTEMICVOL'
    AND (mkt_idx_z.systemic_vol_current / NULLIF(mkt_idx_z.systemic_vol_max, 0) * 100)
        BETWEEN thr_systemic_vol.from_value AND thr_systemic_vol.to_value
LEFT JOIN mkt_cap_today
    ON mkt_cap_today.trading_dt = mkt_idx_z.trading_dt
-- [FIX 2026-09-29] mkt_cap_vsdc_window PHAI JOIN TRUOC thr_turnover_velocity
-- vi dieu kien ON cua thr_turnover_velocity ben duoi can dung cot cua no
-- (loi UNRESOLVED_COLUMN khi build lan dau: JOIN mkt_cap_vsdc_window truoc
-- day nam SAU thr_turnover_velocity trong chuoi FROM/JOIN nen chua "nhin
-- thay" duoc).
LEFT JOIN mkt_cap_vsdc_window
    ON mkt_cap_vsdc_window.trading_dt = mkt_idx_z.trading_dt
LEFT JOIN tvi_num
    ON tvi_num.trading_dt = mkt_idx_z.trading_dt   -- [BACKFILL-UAT-NEW] daily: CROSS JOIN
LEFT JOIN tvi_den
    ON tvi_den.trading_dt = mkt_idx_z.trading_dt
LEFT JOIN status_thr thr_turnover_velocity
    ON thr_turnover_velocity.index_code = 'TVI'
    AND (tvi_num.total_trading_val_stock / NULLIF(tvi_den.total_market_cap_free_float, 0) * 100)
        BETWEEN thr_turnover_velocity.from_value AND thr_turnover_velocity.to_value
-- [BACKFILL-UAT-NEW] khong loc ngay: nap toan bo cac phien co trong atomic
