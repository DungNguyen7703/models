/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_public_company_financial_smy_snpst
* Program name: Dtm Fct Public Company Financial Summary Snpst
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-15			duc.luxuan			Bo sung 5 cot luy ke tu dau nam (BA yeu cau,
*								Nhom 7/8/11): net_profit_ytd, net_revenue_ytd, pre_tax_profit_ytd
*								(SUM theo column_description_reference='3', cung row voi cot ky nay),
*								roa_ytd/roe_ytd (= net_profit_ytd / trung binh voi cot dau nam,
*								column_description_reference='2'). CHUA co tien le dung col_desc='3'
*								trong GSDC - can BA/Data Steward xac nhan on dinh nghia qua cac nam/catalog.
*								LUU Y TRIEN KHAI: model dung incremental_strategy=append, KHONG tu schema
*								evolution - PHAI ALTER TABLE ADD COLUMNS thu cong truoc khi dbt run, TUYET
*								DOI KHONG dung --full-refresh (xoa lich su cac ngay cu, SQL chi tinh dung 1
*								ngay etl_date/lan chay). Da cap nhat kem ClickHouse flat
*								(gsdc_fct_public_company_financial_smy_snpst_flat.sql) - flat nay dung
*								ck_snapshot nen cung can ALTER TABLE thu cong tren ClickHouse truoc deploy.
*								BI Mapping CSV (DTM_GSDC_Detail_Mapping.csv, K_GSDC_*) chua duoc cap nhat -
*								nam ngoai pham vi dbt project, can lam rieng.
* 2026-09-19		duc.luxuan			Bo filter "rpt_year=YEAR(etl_date) AND rpt_quarter=
*								QUARTER(etl_date)" (va nhanh rieng cho quarter IN (5,6)) o
*								report_submission_raw va fr_value_raw. Ly do: nguoi yeu cau xac
*								nhan 2 van de nghiep vu (1) cong ty KHONG bi gioi han thoi gian phai
*								nop bao cao (da co bang chung thuc te tu Oracle - xem changelog
*								2026-09-19 cua dtm_public_company_regulatory_compliance_rpt.sql: 380
*								dong tre >1 nam, 16 dong tre >10 nam, khong tim thay tran phap ly ro
*								rang) va (2) cong ty co the nop lai nhieu lan cho cung 1 ky/loai bao
*								cao. Voi filter cu, model nay CHI BAO GIO tinh dung 1 ky hien hanh
*								(rpt_year/rpt_quarter = YEAR/QUARTER(etl_date)) - bat ky submission
*								nao cho ky QUA KHU (nop muon, hoac nop lai/sua sau khi ky da troi qua)
*								deu bi loai bo NGAY TU DAU, khong bao gio duoc phan anh vao fact nay,
*								bat ke atm_pc_report_submission_hstr/atm_fr_value_hstr (SCD4a) moi ngay
*								van la full snapshot toan bo lich su (da doi chieu: 2 CTE nguon
*								nay khong co filter theo ky, chi loc ds_snpst_dt/ds_rcrd_st/
*								src_stm_code) - filter ky hien hanh la gioi han TU AP DAT o tang
*								datamart nay, khong phai gioi han cua nguon.
*								Fix: bo han 2 nhanh filter ky, giu lai CHI filter ky thuat
*								(ds_snpst_dt=etl_date, ds_rcrd_st=ACTIVE, src_stm_code, va
*								submission_status_code=APPROVED rieng cho report_submission_raw) -
*								dung y het pattern da ap dung cho dtm_fct_violation_rpt_snpst.sql
*								(entry 2026-08-26): moi ngay chay lai TOAN BO lich su cac ky da tung
*								phat sinh submission/gia tri, khong chi ky hien hanh.
*								Van de (2) - nop lai nhieu lan: KHONG can sua them, da xu ly dung tu
*								truoc boi report_submission_ranked (ROW_NUMBER theo pc_code+rpt_year+
*								rpt_quarter, uu tien loai form roi submission_dt DESC) va fr_value_raw
*								(ROW_NUMBER theo pc_id+rpt_year+rpt_quarter+fr_catalog_id+row_code+
*								column_code, order ds_rcrd_udt_dt DESC) - logic "lay ban ghi/gia tri
*								MOI NHAT" nay truoc gio van dung nhung bi VO HIEU HOA cho cac ky qua
*								khu vi bi filter ky hien hanh chan mat truoc khi toi buoc dedup.
*								Anh huong: model tu "moi ngay 1 partition chi chua ky hien hanh" thanh
*								"moi ngay 1 partition la full snapshot toan bo lich su" - dung y do
*								voi materialization append/partition_by=snpst_dt_dim_id (khong doi
*								config). Downstream (dtm_public_company_regulatory_compliance_rpt.sql/
*								CTE financial_summary_dedup, gsdc_fct_public_company_financial_smy_snpst_flat.sql)
*								da duoc thiet ke theo pattern "lay snapshot gan nhat <= asof" nen
*								khong can sua them o buoc nay (flat chi filter snpst_dt_dim_id=
*								etl_date, khong gia dinh gi ve rpt_year/rpt_quarter - da kiem tra).
*								DANH DOI can luu y: volume quet atm_fr_value_hstr/atm_pc_report_submission_hstr
*								moi ngay tang dang ke (tu 1 ky len N ky x nhieu nam lich su) - fr_value
*								la fact RONG (nhieu dong/cong ty/ky do co nhieu row_code x column_code),
*								chi phi Spark scan/GROUP BY se cao hon han so voi violation job. CHUA
*								do luong that thoi gian chay - can DBA theo doi sau khi trien khai, xem
*								xet them chien luoc prune/partition neu can. CHUA chay/doi chieu voi
*								datamart.uat_dtm - can BA/data steward xac nhan lai cac cot profit/YTD
*								cho cac ky lich su moi xuat hien truoc khi release.
* 2026-09-21		duc.luxuan			Doi kieu cot roa/roe/roa_ytd/roe_ytd/debt_to_equity
*								tu DECIMAL(9,4) sang DECIMAL(35,2) tren bang dich
*								datamart.uat_dtm.fct_public_company_financial_smy_snpst
*								(Spark/Hive) va gsdc_fct_public_company_financial_smy_snpst_flat
*								(ClickHouse). Ly do: cong thuc ROUND(SUM(...)/NULLIF(mau_so,0)*100,2)
*								co the tra gia tri rat lon khi mau so (total_asset/equity dau+cuoi ky)
*								gan 0 nhung khac 0 (du lieu bao cao bat thuong, khong bi NULLIF chan) -
*								gay CAST_OVERFLOW_IN_TABLE_INSERT khi insert vao cot DECIMAL(9,4) cu,
*								lam FAIL toan bo dbt run (khong chi 1 dong). Da xac nhan voi user du lieu
*								thuc te co case nay. LUU Y TRIEN KHAI: PHAI ALTER TABLE CHANGE COLUMN
*								thu cong ca 2 phia (Spark va ClickHouse) TRUOC khi chay lai dbt run,
*								model KHONG tu schema evolution (dung incremental_rebase/ck_snapshot).
*								Logic tinh toan SQL khong doi (van ROUND(...,2)), chi mo rong gioi han
*								precision cot dich de tranh mat du lieu do outlier mau so qua nho.
* 2026-09-22		duc.luxuan			Atomic doi co che (scd4a --> scd2/upsert) cho
*								atm_pc_report_submission, atm_financial_report, atm_fr_value,
*								atm_fr_catalog, atm_fr_row, atm_fr_column.
*								Sua theo dung: bo hau to _hstr + bo dieu kien ds_snpst_dt (doc
*								thang bang current-state, khong con bang lich su rieng), doi
*								submission_status_code --> approval_status_code
*								(atm_pc_report_submission). Van giu ds_rcrd_st = 'ACTIVE' (soft
*								delete flag khong doi). Khong doi ten/kieu cot output cua Mart
*								nay, chi doi phia tham chieu nguon.
* 2026-10-01		duc.luxuan			Bo sung 7 cot dau ky (BCDKT, column_description_reference='2',
*								giu nguyen dieu kien row/enterprise_tp cua cot ky nay tuong ung):
*								6 cot co so total_liability_beginning, contributed_capital_beginning,
*								inventory_beginning, undistributed_profit_beginning,
*								receivable_beginning, cash_and_equivalent_beginning (dat ngay sau
*								equity_beginning) + 1 cot phai sinh debt_to_equity_beginning
*								= total_liability_beginning / equity_beginning (dat ngay sau
*								debt_to_equity). INSERT theo vi tri cot => PHAI ALTER TABLE ADD
*								COLUMN ... AFTER thu cong tren Iceberg (datamart.uat_dtm) va
*								ClickHouse flat TRUOC khi dbt run. KHONG --full-refresh.
* 2026-10-02		duc.luxuan			Doi kieu du lieu: 22 cot chi tieu co so CAST tuong minh decimal(38,8) (truoc la SUM(decimal(20,2)) ngam dinh);
*								6 cot phai sinh tu phep chia (roa, roe, roa_ytd, roe_ytd, debt_to_equity,
*								debt_to_equity_beginning) bo ROUND(...,2), CAST decimal(30,6).
*								Nguon: atm_fr_value.data_val doi decimal(20,2) -> decimal(38,8). Quy uoc: cot
*								chi tieu co so = (38,8), cot tinh tu phep chia = (30,6). Bang Iceberg KHONG doi
*								scale tai cho + INSERT theo vi tri => PHAI chay DDL
*								lakehouse_ubck_v1/ddl/20261002_gsdc_decimal_{iceberg,clickhouse}.sql TRUOC dbt run. KHONG --full-refresh.
* 2026-10-02		duc.luxuan			Sua thu tu phep tinh %: X / NULLIF(Y,0) * 100 -> X * 100 / NULLIF(Y,0) (4 cot roa/roe/roa_ytd/roe_ytd).
*									  Spark ep scale ket qua phep chia decimal(38,x)/decimal(38,x) ve 6 => chia truoc
*									  roi *100 chi con 4 chu so thap phan dung (vd 3.215200 thay vi 3.215241).
* 2026-10-02		duc.luxuan			ROA/ROE (roa, roe, roa_ytd, roe_ytd) theo logic BA: tach SELECT tong hop thanh CTE smy_base,
*									  tinh ROA/ROE o SELECT ngoai; mau so = trung binh dau ky/cuoi ky, ben nao NULL hoac = 0 thi
*									  lay cot con lai (truoc la SUM(dau ky) + SUM(cuoi ky) => thieu 1 ben ra NULL). Thu tu cot giu nguyen.
*--------------------------------------------------------------------*
*/

WITH report_submission_raw AS (
    SELECT
        pc_code,
        rpt_year,
        rpt_quarter,
        fr_id,
        submission_dt
    FROM {{ ref('atm_pc_report_submission') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_DATA'
        AND approval_status_code = 'APPROVED'
),

fr_template_periodic AS (
    SELECT
        fr_id,
        fr_code
    FROM {{ ref('atm_financial_report') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_FORMS'
        AND news_tp_code = 'DINH_KY'
),

fr_value_raw AS (
    -- Dedup fr_value: bản ghi mới nhất mỗi (company, kỳ, catalog, row_code, column_code)
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY pc_id, rpt_year, rpt_quarter, fr_catalog_id, row_code, column_code
            ORDER BY ds_rcrd_udt_dt DESC, ds_rcrd_isrt_dt DESC, fr_val_code desc
        ) AS rn
    FROM {{ ref('atm_fr_value') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_DATA'
),

fr_catalog_atomic AS (
    SELECT
        fr_catalog_id,
        fr_year,
        financial_statement_tp_code,
        enterprise_tp_code,
        rpt_code
    FROM {{ ref('atm_fr_catalog') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_REPORT_CATALOG'
),

fr_row_template AS (
    SELECT
        row_code,
        fr_catalog_id,
        rpt_year,
        row_description_reference
    FROM {{ ref('atm_fr_row') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_RROW'
),

fr_column_template AS (
    SELECT
        column_code,
        fr_catalog_id,
        rpt_year,
        column_description_reference
    FROM {{ ref('atm_fr_column') }}
    WHERE ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_RCOL'
),

company AS (
    SELECT
        public_company_dim_id,
        public_company_code,
        business_line_level_1_code
    FROM {{ ref('dtm_public_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'IDS_COMPANY_PROFILES' 
),

industry AS (
    SELECT
        industry_dim_id,
        industry_code
    FROM {{ ref('dtm_industry_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'ECAT_BUSINESS_LINE_LEVEL_1'
),

report_submission_ranked AS (
    SELECT
        report_submission_raw.pc_code,
        report_submission_raw.rpt_year,
        report_submission_raw.rpt_quarter,
        report_submission_raw.fr_id,
        ROW_NUMBER() OVER (
            PARTITION BY report_submission_raw.pc_code, report_submission_raw.rpt_year, report_submission_raw.rpt_quarter
            ORDER BY CASE
                WHEN fr_template_periodic.fr_code LIKE 'HN%' THEN 1
                WHEN fr_template_periodic.fr_code LIKE 'TH%' THEN 2
                WHEN fr_template_periodic.fr_code LIKE 'ME%' THEN 3
                WHEN fr_template_periodic.fr_code LIKE 'RI%' THEN 4
            END, report_submission_raw.submission_dt DESC
        ) AS rn
    FROM report_submission_raw
    INNER JOIN fr_template_periodic
        ON fr_template_periodic.fr_id = report_submission_raw.fr_id
),

-- Chọn 1 form ưu tiên (HN>TH>ME>RI) mỗi (company, kỳ) đã APPROVED, loại tin định kỳ
form_uu_tien AS (
    SELECT
        report_submission_ranked.pc_code,
        report_submission_ranked.rpt_year,
        report_submission_ranked.rpt_quarter,
        fr_template_periodic.fr_code,
        SUBSTR(fr_template_periodic.fr_code, 1, 2) AS financial_statement_tp_code
    FROM report_submission_ranked
    INNER JOIN fr_template_periodic
        ON fr_template_periodic.fr_id = report_submission_ranked.fr_id
    WHERE report_submission_ranked.rn = 1
),

fr_value AS (
    SELECT
        pc_id,
        pc_code,
        rpt_year,
        rpt_quarter,
        fr_catalog_id,
        row_code,
        column_code,
        data_val
    FROM fr_value_raw
    WHERE rn = 1
),

chi_tieu AS (
    SELECT
        fr_value.pc_id,
        fr_value.pc_code,
        fr_value.rpt_year,
        fr_value.rpt_quarter,
        fr_value.data_val,
        fr_catalog_atomic.enterprise_tp_code,
        fr_row_template.row_description_reference,
        fr_column_template.column_description_reference,
        fr_catalog_atomic.rpt_code
    FROM fr_value
    INNER JOIN form_uu_tien
        ON form_uu_tien.pc_code = fr_value.pc_code 
        AND form_uu_tien.rpt_year = fr_value.rpt_year 
        AND form_uu_tien.rpt_quarter = fr_value.rpt_quarter
    INNER JOIN fr_catalog_atomic
        ON fr_catalog_atomic.fr_catalog_id = fr_value.fr_catalog_id
        AND fr_catalog_atomic.fr_year = CAST(fr_value.rpt_year AS STRING)
        AND fr_catalog_atomic.financial_statement_tp_code = form_uu_tien.financial_statement_tp_code
    INNER JOIN fr_row_template
        ON fr_row_template.row_code = fr_value.row_code
        AND fr_row_template.fr_catalog_id = fr_value.fr_catalog_id
        AND fr_row_template.rpt_year = CAST(fr_value.rpt_year AS STRING)
    INNER JOIN fr_column_template
        ON fr_column_template.column_code = fr_value.column_code
        AND fr_column_template.fr_catalog_id = fr_value.fr_catalog_id
        AND fr_column_template.rpt_year = CAST(fr_value.rpt_year AS STRING)
),

smy_base AS (
SELECT
    company.public_company_dim_id                                                  AS public_company_dim_id,
    Date_format(TO_DATE('{{ var("etl_date") }}','yyyy-MM-dd'),'yyyyMMdd')          AS snpst_dt_dim_id,
    industry.industry_dim_id                                                       AS industry_dim_id,
    chi_tieu.rpt_year                                                              AS rpt_year
    ,chi_tieu.rpt_quarter                                                          AS rpt_quarter
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '270')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '300'))
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS total_asset
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '300')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '400'))
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS total_liability
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '400')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '500'))
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS equity
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND chi_tieu.row_description_reference = '411'
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS contributed_capital
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCKQKD%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '60')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '21'))
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS net_profit
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCKQKD%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '50')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '17'))
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS pre_tax_profit
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCKQKD%' AND chi_tieu.column_description_reference = '3'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '60')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '21'))
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS net_profit_ytd
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCKQKD%' AND chi_tieu.column_description_reference = '3'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '10')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '03'))
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS net_revenue_ytd
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCKQKD%' AND chi_tieu.column_description_reference = '3'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '50')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '17'))
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS pre_tax_profit_ytd
     ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '270')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '300'))
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS total_asset_beginning
      ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '400')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '500'))
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS equity_beginning
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '300')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '400'))
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS total_liability_beginning
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND chi_tieu.row_description_reference = '411'
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS contributed_capital_beginning
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '140'
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS inventory_beginning
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '421'
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS undistributed_profit_beginning
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference IN ('130','210'))
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '251'))
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS receivable_beginning
    ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '110')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference IN ('110','120')))
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS cash_and_equivalent_beginning
     ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '140'
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS inventory
     ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCKQKD%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '10')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '03'))
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS net_revenue
     ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '421'
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS undistributed_profit
      ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference IN ('130','210'))
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '251'))
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS receivable
     ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '110')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference IN ('110','120')))
        THEN chi_tieu.data_val END) AS decimal(38,8))                                               AS cash_and_equivalent
      ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '300')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '400'))
        THEN chi_tieu.data_val END)
    / NULLIF(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '1'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '400')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '500'))
        THEN chi_tieu.data_val END), 0) AS decimal(30,6))                                          AS debt_to_equity
      ,CAST(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '300')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '400'))
        THEN chi_tieu.data_val END)
    / NULLIF(SUM(CASE WHEN chi_tieu.rpt_code LIKE 'BCDKT%' AND chi_tieu.column_description_reference = '2'
             AND ((UPPER(chi_tieu.enterprise_tp_code) IN ('DN','BH') AND chi_tieu.row_description_reference = '400')
               OR (UPPER(chi_tieu.enterprise_tp_code) = 'TD' AND chi_tieu.row_description_reference = '500'))
        THEN chi_tieu.data_val END), 0) AS decimal(30,6))                                          AS debt_to_equity_beginning
FROM chi_tieu
INNER JOIN company
    ON company.public_company_code = chi_tieu.pc_code
LEFT JOIN industry
    ON industry.industry_code = company.business_line_level_1_code
GROUP BY
    company.public_company_dim_id ,
    industry.industry_dim_id ,
    chi_tieu.rpt_year,
    chi_tieu.rpt_quarter
)

-- Mau so ROA/ROE theo logic BA: dau ky/cuoi ky NULL hoac = 0 thi lay cot con lai
SELECT
    public_company_dim_id
    ,snpst_dt_dim_id
    ,industry_dim_id
    ,rpt_year
    ,rpt_quarter
    ,total_asset
    ,total_liability
    ,equity
    ,contributed_capital
    ,net_profit
    ,pre_tax_profit
    ,net_profit_ytd
    ,net_revenue_ytd
    ,pre_tax_profit_ytd
    ,total_asset_beginning
    ,equity_beginning
    ,total_liability_beginning
    ,contributed_capital_beginning
    ,inventory_beginning
    ,undistributed_profit_beginning
    ,receivable_beginning
    ,cash_and_equivalent_beginning
    ,inventory
    ,net_revenue
    ,undistributed_profit
    ,receivable
    ,cash_and_equivalent
    ,CAST(net_profit * 100
        / NULLIF((CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END
                + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0)
        AS decimal(30,6))                                                          AS roa
    ,CAST(net_profit * 100
        / NULLIF((CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END
                + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)
        AS decimal(30,6))                                                          AS roe
    ,CAST(net_profit_ytd * 100
        / NULLIF((CASE WHEN COALESCE(total_asset_beginning, 0) = 0 THEN total_asset ELSE total_asset_beginning END
                + CASE WHEN COALESCE(total_asset, 0) = 0 THEN total_asset_beginning ELSE total_asset END) / 2, 0)
        AS decimal(30,6))                                                          AS roa_ytd
    ,CAST(net_profit_ytd * 100
        / NULLIF((CASE WHEN COALESCE(equity_beginning, 0) = 0 THEN equity ELSE equity_beginning END
                + CASE WHEN COALESCE(equity, 0) = 0 THEN equity_beginning ELSE equity END) / 2, 0)
        AS decimal(30,6))                                                          AS roe_ytd
    ,debt_to_equity
    ,debt_to_equity_beginning
FROM smy_base
    
	