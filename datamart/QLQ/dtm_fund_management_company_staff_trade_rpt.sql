/*
*--------------------------------------------------------------------*
* Program code: dtm_fund_management_company_staff_trade_rpt
* Program name: Dtm Fund Management Company Staff Trade Report
* Created by:
* Created date: 2026-10-14
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-14		claude (sync)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_opr_fund_management_company_staff_trade_rpt_ORDERTRADE.csv (commit d18cdaa0)
*                                       Grain: 1 bên mua/bán của 1 giao dịch khớp × 1 nhân viên CTQLQ × 1 ngày. Driving: atm_securities_trade
*                                       (src ORDERTRADE_TRADE_BOOK_HOSE/HNX, trade_dt = etl_date); pivot BUY/SELL bằng UNION ALL, mỗi nhánh
*                                       INNER JOIN fmc_employee theo securities_trading_account_nbr (thay EXISTS của LLD — O_QLQ_35)
*                                       Theo quyết định Data Modeler 2026-10-14: bỏ tiền tố opr_ (model/alias fund_management_company_staff_trade_rpt),
*                                       materialized incremental_rebase/append, partition trade_dt (Fact Append theo ngày giao dịch);
*                                       không SELECT audit SCD4A ds_rcrd_* của LLD (không áp dụng cho append), ds_etl_pcs_tms do macro tự thêm
*                                       LLD/HLD/Entities.csv vẫn ghi opr_/operational tại thời điểm sync -> chờ Design team cập nhật
*                                       identification_nbr, securities_account_nbr: PII đã mã hóa từ nguồn nên là cột thường (HLD O_QLQ_36 (f))
* 2026-10-15		duc.luxuan			Đổi đường nối nhân viên -> tài khoản theo SQL BA nhóm 28: TL_PROFILES.ID_NO (ip_alternative_identification)
*                                       -> VSDC open_investors ∪ updated_investors (id_number -> trading_account_no) -> sổ lệnh buy/sell account.
*                                       Bỏ nối theo fmc_employee.securities_trading_account_nbr (CDY_ACC) vì không khớp được sell/buy_account_nbr.
*                                       Đọc tạm VSDC từ staging do Atomic chưa có entity -> chờ Design team cập nhật LLD/HLD (O_QLQ_35)
* 2026-10-15		claude (sync)		Đồng bộ LLD DTM_QLQ_fund_management_company_staff_trade_rpt_ORDERTRADE.csv (commit aea21863, O_QLQ_35/36/39) — SCHEMA-CHANGING:
*                                       bỏ cột securities_trade_code, board_tp_code; sắp lại thứ tự cột theo grain 6 cột của LLD;
*                                       SELECT DISTINCT toàn bộ cột (tương đương UNION của SQL BA); order_amt = order_vol × order_price
*                                       cả 4 nhánh (LLD: SQL BA nhánh HNX bán dùng trade_quantity × trade_price là lệch cột).
*                                       CẦU NỐI CCCD -> TÀI KHOẢN: KHÔNG dùng discretionary_investment_account như LLD ghi — entity này lấy
*                                       nguồn FMS.INVES_ACC (tài khoản ủy thác tại CTQLQ), không có số giấy tờ chủ tài khoản. Theo quyết định
*                                       Data Modeler 2026-10-15: giữ đúng SQL BA nhóm 28 — VSDC open_investors ∪ updated_investors, đọc từ
*                                       staging vì Atomic chưa có entity (mapping_vsdc_ods_atm.md: "KHÔNG map — xử lý cơ chế riêng").
*                                       -> chờ Design team thiết kế entity Atomic cho VSDC investors + sửa LLD, khi đó chỉ thay CTE investor_account
* 2026-10-15		duc.luxuan			Driving atm_securities_trade: trade_dt = MAX(trade_dt) <= etl_date (ngày giao dịch mới nhất) thay cho trade_dt = etl_date
*--------------------------------------------------------------------*
*/

WITH securities_trade AS (
    SELECT
        trade_dt,
        board_tp_code,
        security_symbol_code,
        buy_account_nbr,
        buy_broker_id,
        buy_order_vol,
        buy_order_price,
        sell_account_nbr,
        sell_broker_id,
        sell_order_vol,
        sell_order_price,
        src_stm_code
    FROM {{ ref('atm_securities_trade') }}
    WHERE src_stm_code IN ('ORDERTRADE_TRADE_BOOK_HOSE','ORDERTRADE_TRADE_BOOK_HNX')
        AND trade_dt = to_date('2026-10-08', 'yyyy-MM-dd')
),

fmc_employee AS (
    SELECT
        fmc_employee_code,
        fmc_code
    FROM {{ ref('atm_fmc_employee') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_TL_PROFILES'
),

ip_alternative_identification AS (
    SELECT
        ip_code,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_TL_PROFILES'
        AND identification_tp_code = 'IDENTIFICATION'
        AND identification_nbr IS NOT NULL
),

-- Cầu nối CCCD -> tài khoản GDCK theo SQL BA nhóm 28 (CTE ivt): VSDC open_investors ∪ updated_investors,
-- lũy kế mọi snapshot <= etl_date; UNION = khử trùng (1 CCCD có thể có nhiều tài khoản và ngược lại — giữ đủ các cặp).
-- [TẠM] Đọc từ staging: Atomic chưa có entity cho 2 bảng này; KHÔNG dùng atm_discretionary_investment_account (nguồn FMS.INVES_ACC).
investor_account AS (
    SELECT 
        trading_account_no, 
        id_number
    FROM {{ source('source_vsdc', 'raw_open_investors') }}
    WHERE 1=1 
        -- AND ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_snpst_dt = (
            SELECT MAX(ds_snpst_dt) 
            FROM {{ source('source_vsdc', 'raw_open_investors') }}
        )
        AND trading_account_no IS NOT NULL
        AND id_number IS NOT NULL
    UNION 
    SELECT 
        trading_account_no, 
        id_number
    FROM {{ source('source_vsdc', 'raw_updated_investors') }}
    WHERE 1=1 
        -- AND ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_snpst_dt = (
            SELECT MAX(ds_snpst_dt) 
            FROM {{ source('source_vsdc', 'raw_updated_investors') }}
        )
        AND trading_account_no IS NOT NULL
        AND id_number IS NOT NULL
),

-- tp.id_no = ivt.id_number của SQL BA: 1 dòng / nhân viên × tài khoản GDCK (1 nhân viên có thể có nhiều tài khoản ở nhiều CTCK)
fmc_employee_account AS (
    SELECT DISTINCT
        fmc_employee.fmc_employee_code,
        fmc_employee.fmc_code,
        ip_alternative_identification.identification_nbr,
        investor_account.trading_account_no
    FROM fmc_employee
    INNER JOIN ip_alternative_identification
        ON ip_alternative_identification.ip_code = fmc_employee.fmc_employee_code
    INNER JOIN investor_account
        ON investor_account.id_number = ip_alternative_identification.identification_nbr
),

-- trade.stk = ivt.trading_account_no của SQL BA (LEFT JOIN + lọc trade_date của BA tương đương INNER JOIN)
staff_trade_buy AS (
    SELECT
        fmc_employee_account.fmc_employee_code,
        securities_trade.trade_dt,
        securities_trade.buy_account_nbr        AS securities_account_nbr,
        'BUY'                                   AS trade_direction_code,
        securities_trade.security_symbol_code,
        securities_trade.board_tp_code,
        fmc_employee_account.fmc_code,
        fmc_employee_account.identification_nbr,
        securities_trade.buy_broker_id          AS securities_company_code,
        'Mua'                                   AS trade_direction_nm,
        securities_trade.buy_order_vol          AS order_vol,
        securities_trade.buy_order_price        AS order_price,
        securities_trade.buy_order_vol * securities_trade.buy_order_price AS order_amt,
        securities_trade.src_stm_code
    FROM securities_trade
    INNER JOIN fmc_employee_account
        ON fmc_employee_account.trading_account_no = securities_trade.buy_account_nbr
),

staff_trade_sell AS (
    SELECT
        fmc_employee_account.fmc_employee_code,
        securities_trade.trade_dt,
        securities_trade.sell_account_nbr       AS securities_account_nbr,
        'SELL'                                  AS trade_direction_code,
        securities_trade.security_symbol_code,
        securities_trade.board_tp_code,
        fmc_employee_account.fmc_code,
        fmc_employee_account.identification_nbr,
        securities_trade.sell_broker_id         AS securities_company_code,
        'Bán'                                   AS trade_direction_nm,
        securities_trade.sell_order_vol         AS order_vol,
        securities_trade.sell_order_price       AS order_price,
        securities_trade.sell_order_vol * securities_trade.sell_order_price AS order_amt,
        securities_trade.src_stm_code
    FROM securities_trade
    INNER JOIN fmc_employee_account
        ON fmc_employee_account.trading_account_no = securities_trade.sell_account_nbr
),

staff_trade AS (
    SELECT * FROM staff_trade_buy
    UNION ALL
    SELECT * FROM staff_trade_sell
)

-- SELECT DISTINCT: khử trùng toàn bộ cột, tương đương UNION của SQL BA (O_QLQ_36)
SELECT DISTINCT
    CAST(staff_trade.fmc_employee_code AS string)                                               AS fmc_employee_code
    , CAST(staff_trade.trade_dt AS date)                                                        AS trade_dt
    , CAST(staff_trade.securities_account_nbr AS string)                                        AS securities_account_nbr
    , CAST(staff_trade.trade_direction_code AS string)                                          AS trade_direction_code
    , CAST(staff_trade.security_symbol_code AS string)                                          AS security_symbol_code
    , CAST(CASE
        WHEN staff_trade.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HOSE' THEN
            CASE staff_trade.board_tp_code
                WHEN 'G1' THEN 'Phiên chính khớp lệnh liên tục'
                WHEN 'G2' THEN 'Phiên định kỳ mở cửa'
                WHEN 'G3' THEN 'Phiên sau đóng cửa'
                WHEN 'G4' THEN 'Giao dịch lô lẻ'
                ELSE 'Khác'
            END
        WHEN staff_trade.src_stm_code = 'ORDERTRADE_TRADE_BOOK_HNX' THEN
            CASE staff_trade.board_tp_code
                WHEN 'G1' THEN 'Phiên chính khớp lệnh liên tục'
                WHEN 'G2' THEN 'Phiên định kỳ mở cửa'
                WHEN 'G3' THEN 'Phiên sau đóng cửa'
                WHEN 'G4' THEN 'Giao dịch lô lẻ'
                WHEN 'G7' THEN 'Giao dịch mua bắt buộc'
                WHEN 'G8' THEN 'Bán giải chấp/bán bắt buộc'
                WHEN 'T1' THEN 'Thỏa thuận'
                WHEN 'T4' THEN 'Thỏa thuận lô lẻ'
                WHEN 'T2' THEN 'Thỏa thuận trước giờ mở cửa'
                WHEN 'T3' THEN 'Thỏa thuận sau giờ giao dịch'
                WHEN 'T6' THEN 'Thỏa thuận sau giờ cho lô lẻ'
                WHEN 'R1' THEN 'Giao dịch repo (mua bán có cam kết mua lại)'
                ELSE 'Khác'
            END
      END AS string)                                                                            AS trade_method_nm
    , CAST(staff_trade.fmc_code AS string)                                                      AS fmc_code
    , CAST(staff_trade.identification_nbr AS string)                                            AS identification_nbr
    , CAST(staff_trade.securities_company_code AS string)                                       AS securities_company_code
    , CAST(staff_trade.trade_direction_nm AS string)                                            AS trade_direction_nm
    , CAST(staff_trade.order_vol AS bigint)                                                     AS order_vol
    , CAST(staff_trade.order_price AS decimal(23,2))                                            AS order_price
    , CAST(staff_trade.order_amt AS decimal(23,2))                                              AS order_amt
    , CAST(staff_trade.src_stm_code AS string)                                                  AS src_stm_code
FROM staff_trade
