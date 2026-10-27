/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_securities_company_financial_structure_snpst
* Program name: Dtm Fct Securities Company Financial Structure Snpst
* Created by: tuan.nguyenvanb
* Created date: 2026-09-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-19		tuan.nguyenvanb		[MOI, theo LLD QLKD Nhom 22] Sinh moi -
*                                       Fact Securities Company Financial
*                                       Structure Snapshot.
*                                       [RANG BUOC ETL 2026-09-18] BA bo
*                                       ORDER BY VERSION DESC FETCH FIRST 1
*                                       ROW ONLY va doi FORM_REPORT_ID =
*                                       thanh IN o nguon Oracle, nen nguon
*                                       tra ve MOI version cua bieu mau.
*                                       Khu trung bang ROW_NUMBER() theo
*                                       khoa (securities_company_dim_id,
*                                       report_indicator_dim_id, rpt_year,
*                                       rpt_period_tp_code, period_nbr,
*                                       rpt_code), giu ban nop moi nhat
*                                       theo submission_dt.
* 2026-10-15		claude			[FIX] Viet lai theo dung khoa join (ap
*                                       dung chain join chuan suy ra tu 3
*                                       bang cung ho da duoc LLD xac nhan ro:
*                                       opr_securities_company_financial_
*                                       report_hist, opr_securities_company_
*                                       practitioner_profile, opr_securities_
*                                       company_report_data - quyet dinh user
*                                       da xac nhan ap dung cho ca 4 bang):
*                                       INNER JOIN sc_report_input_submission
*                                       ON sc_rpt_input_submission_id, INNER
*                                       JOIN sc_periodic_report ON ref_id =
*                                       sc_periodic_rpt_code AND ref_tp_code =
*                                       'BAO_CAO_DINH_KY', INNER JOIN
*                                       securities_company ON sc_id, JOIN
*                                       sc_report de lay dung rpt_code
*                                       nghiep vu (khong phai sc_rpt_code -
*                                       ID ky thuat form_report_id). Bo
*                                       CROSS JOIN/JOIN ON 1=1. Sua ten cot
*                                       item_val -> cell_val theo dung atm_sc_
*                                       report_input_value hien tai.
* 2026-10-15		claude			[FIX] Sua LEFT JOIN re_in_di (Report
*                                       Indicator Dimension) tu chi theo
*                                       cell_id sang dung composite (rpt_code,
*                                       sheet_id, cell_id) theo dung LLD moi
*                                       nhat - truoc day gop nham TS001 cua
*                                       cac sheet khac nhau vi report_
*                                       indicator_dim da doi grain (xem
*                                       dtm_report_indicator_dim.sql).
* 2026-10-19		claude			[SUA] Bo sung cot preferred_report_ind
*                                       (window function theo dung LLD: danh
*                                       dau BCTCRL cua CTCK da co BCTCHN cung
*                                       ky la '0', con lai la '1' - tranh
*                                       cong doi HN/RL khi tinh KPI).
* 2026-10-23		claude			[SUA theo dung LLD, mapping dong 12]
*                                       Bo sung filter bat buoc con thieu:
*                                       sc_report.rpt_tp_code = 'INPUT',
*                                       sc_report.rpt_code IN ('BCTCHN',
*                                       'BCTCRL','BCTLAT','BCTHHD_CTCK'),
*                                       (rpt_code <> 'BCTLAT' OR legal_basis
*                                       LIKE '%102/2025/TT-BTC%'),
*                                       sc_periodic_report.rpt_submission_
*                                       status_code IN ('1','2'). Chuyen
*                                       logic khu trung tu tang Fact cuoi
*                                       (theo dim ids + sent_tms) sang dung
*                                       tang sc_report_input_submission theo
*                                       dung mapping: PARTITION BY ref_tp_
*                                       code, ref_id, rpt_code ORDER BY
*                                       CAST(sc_rpt_input_submission_code AS
*                                       BIGINT) DESC, lay rn = 1 truoc khi
*                                       join tiep sang value/periodic_report.
*                                       [CAN XAC NHAN THEM - 2026-10-23, van
*                                       con hieu luc] LLD yeu cau loc ds_
*                                       rcrd_st = 'ACTIVE' cho sc_report_
*                                       input_submission/sc_periodic_report/
*                                       sc_report nhung atomic hien tai
*                                       (atm_sc_report_input_submission,
*                                       atm_sc_report, atm_sc_periodic_report)
*                                       CHUA expose cot ACTIVE flag tuong
*                                       ung (atm_sc_report chua map active/
*                                       record_status tu ODS form_report,
*                                       atm_sc_periodic_report dang dung
*                                       record_status cho muc dich khac -
*                                       rpt_submission_status_code). Can BA
*                                       xac nhan nguon cot dung truoc khi
*                                       bo sung tang atomic.
* 2026-10-23		claude			[BO SUNG theo LLD cap nhat] Them cot
*                                       rpt_input_submission_id (nguon
*                                       sc_report_input_value.sc_rpt_input_
*                                       submission_id, direct) - dinh danh
*                                       lan nop eForm, phan biet cac lan nop
*                                       cung ky bao cao. Bo sung whitelist
*                                       cell_id theo tung rpt_code vao dieu
*                                       kien loc (dung mapping dong 13):
*                                       BCTCHN 30 cell, BCTCRL 29 cell,
*                                       BCTLAT 1 cell (TS006), BCTHHD_CTCK
*                                       4 cell (TS001/TS008/TS024/TS046) -
*                                       chi lay dung cac o du lieu la chi
*                                       tieu tai chinh can snapshot, loai
*                                       cac cell khac cua cung bieu mau.
* 2026-10-23		claude			[BO SUNG theo dung LLD mapping dong 14]
*                                       Them dieu kien ds_rcrd_st = 'ACTIVE'
*                                       cho sc_rpt (atm_sc_report), sc_rpt_
*                                       in_su_dedup (atm_sc_report_input_
*                                       submission) va sc_pe_rpt (atm_sc_
*                                       periodic_report) - dung yeu cau LLD
*                                       "AND ds_rcrd_st = 'ACTIVE' (ap dung
*                                       cho tung bang Atomic join: sc_report_
*                                       input_submission, sc_periodic_report,
*                                       securities_company, sc_report)".
*                                       [PHU THUOC ATOMIC - CHUA THE CHAY]
*                                       3 atomic tren (deu materialized scd2)
*                                       HIEN CHUA co cot ds_rcrd_st trong
*                                       final SELECT - model se loi compile
*                                       (column not found) cho toi khi atomic
*                                       duoc bo sung cot nay. Day la quyet
*                                       dinh tam thoi da duoc user xac nhan:
*                                       sua datamart truoc theo dung LLD, bo
*                                       sung atomic sau.
* 2026-10-23		claude			[FIX loi runtime AMBIGUOUS_REFERENCE]
*                                       CTE sc_rpt_in_su_dedup SELECT cot
*                                       sc_rpt_id khong chi ro alias nguon,
*                                       trong khi ca atm_sc_report_input_
*                                       submission (alias sc_rpt_in_su) va CTE
*                                       sc_rpt deu co cot nay - Spark khong
*                                       resolve duoc. Them alias ro rang
*                                       (sc_rpt_in_su.xxx AS xxx) cho toan bo
*                                       cot trong SELECT list cua CTE nay.
* 2026-10-23		claude			[FIX - user phat hien thieu PK] Bo sung
*                                       cot rpt_input_val_id con thieu hoan
*                                       toan (nguon sc_report_input_value.
*                                       sc_rpt_input_val_id, direct) - dung
*                                       mapping dong 2: day la PK cua Fact,
*                                       grain = 1 dong Atomic (sc_report_
*                                       input_value), la khoa MERGE/UPSERT
*                                       duy nhat. Sua kieu indicator_val_amt
*                                       tu decimal(23,2) sang decimal(25,2)
*                                       theo dung DDL chuan user cung cap.
*                                       Doi incremental_strategy tu 'append'
*                                       sang 'merge' voi unique_key =
*                                       rpt_input_val_id (xem schema_dtm_qlkd.
*                                       yml) - khop voi ghi chu DDL "co che
*                                       merge theo rpt_input_val_id". Bo
*                                       partition_by (khong con can thiet voi
*                                       strategy merge, theo dung pattern
*                                       dtm_cdr_dt_dim). Luu y: voi strategy
*                                       merge, macro incremental_rebase se tu
*                                       sinh them cot ds_snpst_dt (date) va
*                                       ds_etl_pcs_tms (timestamp) - khong can
*                                       SELECT thu cong trong model.
* 2026-10-24		claude			[SUA theo dung LLD mapping - cot FK/DD]
*                                       Thay dieu kien sai `sc_report_input_
*                                       value.data_dt = etl_date` bang dung
*                                       dieu kien LLD yeu cau tren sc_report_
*                                       input_submission: data_dt = MAX(data_dt)
*                                       cua cung sc_rpt_input_submission_id -
*                                       co lap version hien hanh, tranh nhan
*                                       dong khi Atomic APPEND ban ghi moi luc
*                                       nop lai (O_QLKD_55).
*                                       [PHU THUOC ATOMIC - CHUA THE CHAY]
*                                       atm_sc_report_input_submission va
*                                       atm_sc_report_input_value HIEN CHUA
*                                       SELECT cot data_dt trong output (du
*                                       ODS da co san created_at/last_modified_
*                                       at/data_dt nguon) - model se loi
*                                       compile (column not found) cho toi khi
*                                       Atomic duoc bo sung cot nay. Quyet dinh
*                                       tam thoi da duoc user xac nhan
*                                       2026-10-24: sua datamart truoc theo
*                                       dung LLD, bo sung atomic sau (cung
*                                       pattern da ap dung voi ds_rcrd_st).
*--------------------------------------------------------------------*
*/

WITH sc_rpt_in_va AS (
    SELECT
        sc_rpt_input_val_id,
        cell_id,
        sheet_id,
        cell_val,
        sc_rpt_input_submission_id,
        src_stm_code
    FROM {{ ref('atm_sc_report_input_value') }}
    WHERE src_stm_code = 'SCMS_REPORT_INPUT_CELL_VALUE'
),

sc_rpt AS (
    SELECT
        sc_rpt_id,
        rpt_code,
        rpt_tp_code,
        legal_basis
    FROM {{ ref('atm_sc_report') }}
    WHERE rpt_tp_code = 'INPUT'
        AND rpt_code IN ('BCTCHN', 'BCTCRL', 'BCTLAT', 'BCTHHD_CTCK')
        AND (rpt_code <> 'BCTLAT' OR legal_basis LIKE '%102/2025/TT-BTC%')
        AND ds_rcrd_st = 'ACTIVE'
),

sc_rpt_in_su_dedup AS (
    SELECT
        sc_rpt_in_su.sc_rpt_input_submission_id                      AS sc_rpt_input_submission_id,
        sc_rpt_in_su.sc_rpt_id                                       AS sc_rpt_id,
        sc_rpt_in_su.ref_id                                          AS ref_id,
        sc_rpt_in_su.ref_tp_code                                     AS ref_tp_code,
        sc_rpt_in_su.data_dt,
        row_number() over (
            partition by sc_rpt_in_su.ref_tp_code, sc_rpt_in_su.ref_id, sc_rpt.rpt_code
            order by CAST(sc_rpt_in_su.sc_rpt_input_submission_code AS bigint) desc
        ) as rn
    FROM {{ ref('atm_sc_report_input_submission') }} sc_rpt_in_su
    INNER JOIN sc_rpt
        ON  sc_rpt.sc_rpt_id = sc_rpt_in_su.sc_rpt_id
    WHERE sc_rpt_in_su.ref_tp_code = 'BAO_CAO_DINH_KY'
    AND sc_rpt_in_su.data_dt = (
        SELECT MAX(sub_ver.data_dt)
        FROM {{ ref('atm_sc_report_input_submission') }} sub_ver
        WHERE sub_ver.sc_rpt_input_submission_id = sc_rpt_in_su.sc_rpt_input_submission_id
    )
),

sc_rpt_in_su AS (
    SELECT
        sc_rpt_input_submission_id,
        sc_rpt_id,
        ref_id,
        ref_tp_code
    FROM sc_rpt_in_su_dedup
    WHERE rn = 1
),

sc_pe_rpt AS (
    SELECT
        sc_id,
        sc_code,
        sc_periodic_rpt_code,
        rpt_year,
        rpt_period,
        period,
        end_dt,
        sent_tms,
        rpt_submission_status_code
    FROM {{ ref('atm_sc_periodic_report') }}
    WHERE src_stm_code = 'SCMS_SC_FIRM_PERIODIC_REPORT'
        AND rpt_submission_status_code IN ('1', '2')
        AND ds_rcrd_st = 'ACTIVE'
),

cd_dt_di AS (
    SELECT cdr_dt_dim_id, cdr_dt
    FROM {{ ref('dtm_cdr_dt_dim') }}
),

se_co AS (
    SELECT sc_id, sc_code
    FROM {{ ref('atm_securities_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
),

se_co_di AS (
    SELECT securities_company_dim_id, sc_code
    FROM {{ ref('dtm_securities_company_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
),

re_in_di AS (
    SELECT report_indicator_dim_id, rpt_code, sheet_id, cell_id
    FROM {{ ref('dtm_report_indicator_dim') }}
),

joined AS (
    SELECT
        sc_rpt_in_va.sc_rpt_input_val_id                             AS rpt_input_val_id,
        cd_dt_di.cdr_dt_dim_id                                       AS snpst_dt_dim_id,
        se_co_di.securities_company_dim_id                           AS securities_company_dim_id,
        re_in_di.report_indicator_dim_id                             AS report_indicator_dim_id,
        sc_rpt_in_va.sc_rpt_input_submission_id                      AS rpt_input_submission_id,
        sc_pe_rpt.rpt_year                                           AS rpt_year,
        sc_pe_rpt.rpt_period                                         AS rpt_period_tp_code,
        sc_pe_rpt.period                                             AS period_nbr,
        TRY_CAST(sc_rpt_in_va.cell_val AS decimal(25,2))             AS indicator_val_amt,
        sc_rpt.rpt_code                                              AS rpt_code,
        CAST(sc_pe_rpt.sent_tms AS date)                             AS submission_dt,
        sc_pe_rpt.rpt_submission_status_code                         AS submission_status_code,
        sc_rpt_in_va.src_stm_code                                    AS src_stm_code,
        CAST(
            CASE
                WHEN sc_rpt.rpt_code = 'BCTCRL'
                    AND MAX(CASE WHEN sc_rpt.rpt_code = 'BCTCHN' AND sc_pe_rpt.rpt_submission_status_code IN ('1','2') THEN 1 ELSE 0 END)
                        OVER (PARTITION BY sc_pe_rpt.sc_code, sc_pe_rpt.rpt_year, sc_pe_rpt.rpt_period, sc_pe_rpt.period) = 1
                THEN '0'
                ELSE '1'
            END AS string)                                            AS preferred_report_ind
    FROM sc_rpt_in_va
    INNER JOIN sc_rpt_in_su
        ON  sc_rpt_in_su.sc_rpt_input_submission_id = sc_rpt_in_va.sc_rpt_input_submission_id
    INNER JOIN sc_pe_rpt
        ON  sc_pe_rpt.sc_periodic_rpt_code = sc_rpt_in_su.ref_id
        AND sc_rpt_in_su.ref_tp_code = 'BAO_CAO_DINH_KY'
    INNER JOIN se_co
        ON  se_co.sc_id = sc_pe_rpt.sc_id
    JOIN sc_rpt
        ON  sc_rpt.sc_rpt_id = sc_rpt_in_su.sc_rpt_id
    LEFT JOIN cd_dt_di
        ON  cd_dt_di.cdr_dt = sc_pe_rpt.end_dt
    LEFT JOIN se_co_di
        ON  se_co_di.sc_code = se_co.sc_code
    LEFT JOIN re_in_di
        ON  re_in_di.rpt_code = sc_rpt.rpt_code
        AND re_in_di.sheet_id = COALESCE(sc_rpt_in_va.sheet_id, '')
        AND re_in_di.cell_id = sc_rpt_in_va.cell_id
    WHERE
        (sc_rpt.rpt_code = 'BCTCHN' AND sc_rpt_in_va.cell_id IN (
            'TS003', 'TS011', 'TS013', 'TS015', 'TS017', 'TS019', 'TS021', 'TS023', 'TS025', 'TS027',
            'TS029', 'TS031', 'TS121', 'TS141', 'TS147', 'TS149', 'TS151', 'TS153', 'TS273', 'TS279',
            'TS323', 'TS359', 'TS361', 'TS365', 'TS371', 'TS383', 'TS385', 'TS387', 'TS389', 'TS401'
        ))
        OR (sc_rpt.rpt_code = 'BCTCRL' AND sc_rpt_in_va.cell_id IN (
            'TS003', 'TS007', 'TS011', 'TS013', 'TS015', 'TS017', 'TS019', 'TS021', 'TS023', 'TS025',
            'TS027', 'TS029', 'TS031', 'TS119', 'TS133', 'TS135', 'TS141', 'TS185', 'TS221', 'TS223',
            'TS225', 'TS229', 'TS235', 'TS247', 'TS249', 'TS251', 'TS253', 'TS261', 'TS263'
        ))
        OR (sc_rpt.rpt_code = 'BCTLAT' AND sc_rpt_in_va.cell_id = 'TS006')
        OR (sc_rpt.rpt_code = 'BCTHHD_CTCK' AND sc_rpt_in_va.cell_id IN ('TS001', 'TS008', 'TS024', 'TS046'))
)

SELECT
    CAST(rpt_input_val_id AS string)        AS rpt_input_val_id,
    CAST(snpst_dt_dim_id AS string)         AS snpst_dt_dim_id,
    CAST(securities_company_dim_id AS string) AS securities_company_dim_id,
    CAST(report_indicator_dim_id AS string)   AS report_indicator_dim_id,
    CAST(rpt_input_submission_id AS string)   AS rpt_input_submission_id,
    CAST(rpt_year AS int)                     AS rpt_year,
    CAST(rpt_period_tp_code AS string)        AS rpt_period_tp_code,
    CAST(period_nbr AS int)                   AS period_nbr,
    CAST(indicator_val_amt AS decimal(25,2))  AS indicator_val_amt,
    CAST(rpt_code AS string)                  AS rpt_code,
    CAST(submission_dt AS date)               AS submission_dt,
    CAST(submission_status_code AS string)    AS submission_status_code,
    CAST(preferred_report_ind AS string)      AS preferred_report_ind,
    CAST(src_stm_code AS string)              AS src_stm_code
FROM joined
