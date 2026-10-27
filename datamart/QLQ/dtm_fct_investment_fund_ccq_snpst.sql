/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_investment_fund_ccq_snpst
* Program name: Dtm Fct Investment Fund Ccq Snpst
* Created by: 
* Created date: 2026-09-28
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-28		claude (draft)		Khởi tạo từ LLD Datamart/lld/QLQ/DTM_QLQ_fct_investment_fund_ccq_snpst.csv
*                                       Grain: 1 loại hình quỹ (fund_tp_code) / snapshot
*                                       fund_tp_cl_dim_id: LEFT JOIN dtm_cl_dim (schema FMS_FUND_TYPE) — nếu scheme chưa nạp vào
*                                       cl_value thì cột = NULL (LLD khai not null) — cần Data Modeler xác nhận
* 2026-09-29		claude (draft)		Đổi nguồn atm_* sang bảng Dim QLQ tương ứng (dtm_*_dim_hstr) cho các entity đã có Dim
* 2026-10-07		claude (sync)		Đồng bộ LLD theo Atomic FMS UAT 20261006 (commit 117654ae, 53443cc1): fund_tp_code của Dim nay = cl_fms_fund_tp_code (logic không đổi);
*                                       bỏ cột CTE không dùng operation_status_code, net_asset_val_amt
* 2026-10-10		claude				outstanding_unit_quantity int -> bigint theo LLD sửa 2026-10-08 (tránh tràn số âm) (schema-changing)
*                                       LỆCH LLD (chờ cập nhật): scheme FMS_FUND_TYPE đã promote khỏi cl_value sang atm_cl_fms_fund_type
*                                       -> bỏ join dtm_cl_dim, join dtm_fund_type_dim_hstr theo ds_snpst_dt = etl_date (as-of, đúng khi backfill);
*                                       đổi FK fund_tp_cl_dim_id -> fund_type_id (schema-changing)
* 2026-10-24		claude (sync)		Đồng bộ LLD commit 7164d9ca: outstanding_unit_quantity chỉ cộng quỹ có giấy tờ
*                                       ESTABLISHMENT_OPERATION_LICENSE với last_day(issue_dt) <= last_day(etl_date)
*                                       (cùng tập quỹ với dtm_fct_investment_fund_count_snpst.fund_count)
*--------------------------------------------------------------------*
*/

WITH establishment_license AS (
    SELECT DISTINCT
        ip_id
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
        AND identification_tp_code = 'ESTABLISHMENT_OPERATION_LICENSE'
        AND last_day(identification_issue_dt) <= last_day(to_date('{{ var("etl_date") }}','yyyy-MM-dd'))
),

investment_fund AS (
    SELECT
        investment_fund_id,
        fund_tp_code,
        total_outstanding_unit_quantity,
        src_stm_code
    FROM {{ ref('dtm_investment_fund_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUNDS'
),

agg AS (
    SELECT
        investment_fund.fund_tp_code,
        investment_fund.src_stm_code,
        SUM(investment_fund.total_outstanding_unit_quantity) AS outstanding_unit_quantity
    FROM investment_fund
    INNER JOIN establishment_license
        ON establishment_license.ip_id = investment_fund.investment_fund_id
    GROUP BY 
        investment_fund.fund_tp_code, 
        investment_fund.src_stm_code
),

fund_tp AS (
    SELECT
        fund_type_id,
        fund_type_code
    FROM {{ ref('dtm_fund_type_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'FMS_FUND_TYPE'
)

SELECT
    date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')                     AS snpst_dt_dim_id
    , CAST(fund_tp.fund_type_id AS string)                                                      AS fund_type_id
    , CAST(agg.outstanding_unit_quantity AS bigint)                                             AS outstanding_unit_quantity
    , CAST(agg.src_stm_code AS string)                                                          AS src_stm_code
FROM agg
LEFT JOIN fund_tp
    ON fund_tp.fund_type_code = agg.fund_tp_code
