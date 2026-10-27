/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_practitioner_list_company_role
* Program name: Dtm Opr Practitioner List Company Role
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-08-12		Dai					Grain (practitioner_code, securities_company_code) theo LLD.
* 2026-09-11		nam.tranhoai		Driving đổi sang dtm_securities_practitioner_dim (chỉ NHN có Certificate_Record);
*										join nhnck_id qua securities_practitioner_dim_id (= sp_id).
* 2026-10-22		duc.luxuan			BA update Nhóm 7 (panel TÀI KHOẢN): nạp 4 cột VSDC (trước để NULL) từ
*										atm_investment_account + atm_major_shareholder_ownership; bỏ lọc
*										individual_indicator (SCMS shareholder) và listed_indicator (SCMS firm) theo BA.
*--------------------------------------------------------------------*
* [ĐÁNH ĐỔI ĐÃ CHẤP NHẬN 2026-10-22 — GIỮ GRAIN, KHÁC SQL BA]
* SQL BA ra 1 dòng / (NHN x tài khoản x mã CK cổ đông lớn x CTCK) — tích Descartes vì 3 nguồn chỉ cùng nối
* qua CCCD, không quan hệ với nhau. Mart giữ grain (practitioner_code, securities_company_code), gộp VSDC
* về 1 dòng / NHN rồi gắn vào mọi dòng CTCK của NHN đó:
*   1. NHN nhiều tài khoản -> chỉ lấy TK mở gần nhất (event_dt DESC, ds_snpst_dt DESC, số TK DESC).
*   2. NHN nhiều mã CK cổ đông lớn -> chỉ lấy "mã CK chính" = closing_share_quantity lớn nhất
*      (hòa thì ticker_symbol ASC), snapshot mới nhất <= etl_date. Dashboard ít dòng hơn SQL BA.
*   3. Cột VSDC lặp lại ở mọi dòng CTCK của cùng NHN, không gắn với CTCK đó -> BI KHÔNG SUM
*      vsdc_held_securities_vol theo dòng, hiển thị như thông tin cấp NHN.
*   4. LEFT JOIN (BA dùng INNER JOIN) để Nhóm 6 không mất dòng -> panel TÀI KHOẢN lọc account_nbr IS NOT NULL.
*   5. vsdc_held_securities_vol giữ int theo LLD (nguồn bigint) — tràn nếu > 2.147.483.647 CP.
*   6. Lệch LLD: LLD ghi discretionary_investment_account/major_shareholder (thực tế là bảng FMS / tên cũ),
*      code dùng atm_investment_account/atm_major_shareholder_ownership — chờ Data Modeler cập nhật LLD.
*--------------------------------------------------------------------*
*/

WITH sp AS (
    SELECT
        securities_practitioner_dim_id,
        practitioner_code,
        practice_status_code,
        src_stm_code
    FROM {{ ref('dtm_securities_practitioner_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

nhnck_id AS (
    SELECT
        ip_id,
        identification_nbr
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'NHNCK_PROFESSIONALS'
),

scms_shareholder_id AS (
    SELECT
        identification_nbr,
        ip_id
    FROM {{ ref('atm_ip_alternative_identification') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_SHAREHOLDER'
),

sc_shareholder AS (
    SELECT
        sc_shareholder_id,
        sc_id,
        representative_position,
        shares_held
    FROM {{ ref('atm_sc_shareholder') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_SHAREHOLDER'
),

securities_company AS (
    SELECT
        sc_id,
        sc_code,
        sc_short_nm
    FROM {{ ref('atm_securities_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
),

-- VSDC open_investors (nhận ~1 lần/tuần, Atomic tích lũy theo ds_snpst_dt): 1 TK cá nhân / CCCD (đánh đổi #1)
vsdc_account AS (
    SELECT
        identification_nbr,
        investment_account_nbr,
        investor_nm
    FROM (
        SELECT
            identification_nbr,
            investment_account_nbr,
            investor_nm,
            ROW_NUMBER() OVER (
                PARTITION BY identification_nbr
                ORDER BY event_dt DESC, ds_snpst_dt DESC, investment_account_nbr DESC
            ) AS rn
        FROM {{ ref('atm_investment_account') }}
        WHERE ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            AND investment_account_tp_code IN ('3','4')
            AND identification_nbr IS NOT NULL
    ) x
    WHERE rn = 1
),

-- VSDC major_shareholder: snapshot mới nhất <= etl_date, 1 mã CK chính / CCCD (đánh đổi #2)
vsdc_major_shareholder AS (
    SELECT
        identification_nbr,
        ticker_symbol,
        closing_share_quantity
    FROM (
        SELECT
            identification_nbr,
            ticker_symbol,
            closing_share_quantity,
            ROW_NUMBER() OVER (
                PARTITION BY identification_nbr
                ORDER BY closing_share_quantity DESC NULLS LAST, ticker_symbol ASC
            ) AS rn
        FROM {{ ref('atm_major_shareholder_ownership') }}
        WHERE ds_snpst_dt = (
                SELECT MAX(ds_snpst_dt)
                FROM {{ ref('atm_major_shareholder_ownership') }}
                WHERE ds_snpst_dt <= to_date('{{ var("etl_date") }}','yyyy-MM-dd')
            )
            AND identification_nbr IS NOT NULL
    ) x
    WHERE rn = 1
)

SELECT
    CAST(sp.practitioner_code AS string)                         AS practitioner_code,
    COALESCE(CAST(securities_company.sc_code AS string), 'NULL') AS securities_company_code,
    CAST(securities_company.sc_short_nm AS string)               AS securities_company_short_nm,
    CAST(sc_shareholder.representative_position AS string)       AS representative_position,
    CAST(sp.practice_status_code AS string)                      AS practice_status_code,
    CAST(sc_shareholder.shares_held AS int)                      AS shares_held,
    CAST(vsdc_account.investment_account_nbr AS string)          AS account_nbr,
    CAST(vsdc_account.investor_nm AS string)                     AS account_holder_nm,
    CAST(vsdc_major_shareholder.ticker_symbol AS string)         AS main_held_securities_code,
    CAST(vsdc_major_shareholder.closing_share_quantity AS int)   AS vsdc_held_securities_vol,
    CAST(sp.src_stm_code AS string)                              AS src_stm_code
FROM sp
LEFT JOIN nhnck_id
    ON  nhnck_id.ip_id = sp.securities_practitioner_dim_id
LEFT JOIN scms_shareholder_id
    ON  scms_shareholder_id.identification_nbr = nhnck_id.identification_nbr
LEFT JOIN sc_shareholder
    ON  sc_shareholder.sc_shareholder_id = scms_shareholder_id.ip_id
LEFT JOIN securities_company
    ON  securities_company.sc_id = sc_shareholder.sc_id
LEFT JOIN vsdc_account
    ON  vsdc_account.identification_nbr = nhnck_id.identification_nbr
LEFT JOIN vsdc_major_shareholder
    ON  vsdc_major_shareholder.identification_nbr = nhnck_id.identification_nbr
