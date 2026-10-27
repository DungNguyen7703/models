/*
*--------------------------------------------------------------------*
* Program code: dtm_opr_securities_company_practitioner_profile
* Program name: Dtm Opr Securities Company Practitioner Profile
* Created by: tuan.nguyenvanb
* Created date: 2026-09-19
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-19		tuan.nguyenvanb		[MOI, theo LLD QLKD Nhom 25] Sinh moi -
*                                       Securities Company Practitioner
*                                       Profile.
* 2026-10-19		claude				[SUA theo LLD moi nhat] Thay CROSS
*                                       JOIN bang khoa join that (giong chain
*                                       dung o dtm_opr_securities_company_
*                                       financial_report_hist): INNER JOIN
*                                       sc_report_input_submission ON
*                                       sc_rpt_input_submission_id, INNER
*                                       JOIN sc_periodic_report ON ref_id =
*                                       sc_periodic_rpt_code AND ref_tp_code =
*                                       'BAO_CAO_DINH_KY', INNER JOIN
*                                       securities_company ON sc_id, INNER
*                                       JOIN sc_report ON sc_rpt_id. Them
*                                       filter bat buoc theo LLD: rpt_code IN
*                                       ('BCTHHD_CTCK','BCHDPS') AND
*                                       ref_tp_code = 'BAO_CAO_DINH_KY' AND
*                                       sent_tms IS NOT NULL - day la dieu
*                                       kien phan biet voi financial_report_
*                                       hist (cung nguon atomic). Sua ten cot
*                                       item_val -> cell_val. Sua lai toan bo
*                                       bo cell_id dung theo LLD (TS017/TS018
*                                       cho BCTHHD_CTCK, TS107/TS115/TS119/
*                                       TS111 cho BCTHHD_CTCK theo bo phan,
*                                       TS009/TS017/TS013 cho BCHDPS) - moi
*                                       CASE WHEN co guard rpt_code tuong ung
*                                       vi TS017 trung ma giua 2 bieu mau.
*                                       unlicensed_practitioner_cnt doi sang
*                                       TS017 - TS018 (tru 2 cell) thay vi doc
*                                       1 cell rieng. Doi SUM -> MAX theo dung
*                                       LLD (khoa join da dung nen khong con
*                                       fan-out). Them cot rpt_code,
*                                       rpt_period_tp_code, submission_status_
*                                       code bi thieu. Sua PK hash du 5 thanh
*                                       phan (sc_code, rpt_code, rpt_year,
*                                       rpt_period, period) theo dung LLD.
* 2026-10-24		claude			[BO SUNG theo dung LLD mapping - moi cot FK/DD/
*                                       src_stm_code] Them dieu kien LLD yeu
*                                       cau tren sc_report_input_submission:
*                                       data_dt = MAX(data_dt) cua cung
*                                       sc_rpt_input_submission_id - co lap
*                                       version hien hanh, tranh nhan dong khi
*                                       Atomic APPEND ban ghi moi luc nop lai
*                                       (O_QLKD_55). Truoc day model khong co
*                                       dieu kien data_dt nao.
*                                       [PHU THUOC ATOMIC - CHUA THE CHAY]
*                                       atm_sc_report_input_submission va
*                                       atm_sc_report_input_value HIEN CHUA
*                                       SELECT cot data_dt trong output - model
*                                       se loi compile (column not found) cho
*                                       toi khi Atomic duoc bo sung cot nay.
*                                       Quyet dinh tam thoi da duoc user xac
*                                       nhan 2026-10-24: sua datamart truoc
*                                       theo dung LLD, bo sung atomic sau.
*--------------------------------------------------------------------*
*/

WITH sc_rpt_in_va AS (
    SELECT
        cell_id,
        cell_val,
        sc_rpt_input_submission_id,
        src_stm_code
    FROM {{ ref('atm_sc_report_input_value') }}
    WHERE src_stm_code = 'SCMS_REPORT_INPUT_CELL_VALUE'
),

sc_rpt_in_su AS (
    SELECT
        sc_rpt_input_submission_id,
        sc_rpt_id,
        ref_id,
        ref_tp_code
    FROM {{ ref('atm_sc_report_input_submission') }} sc_rpt_in_su
    WHERE sc_rpt_in_su.data_dt = (
        SELECT MAX(sub_ver.data_dt)
        FROM {{ ref('atm_sc_report_input_submission') }} sub_ver
        WHERE sub_ver.sc_rpt_input_submission_id = sc_rpt_in_su.sc_rpt_input_submission_id
    )
),

sc_rpt AS (
    SELECT
        sc_rpt_id,
        rpt_code
    FROM {{ ref('atm_sc_report') }}
    WHERE ds_rcrd_st = 'ACTIVE'
),

sc_pe_rpt AS (
    SELECT
        sc_id,
        sc_code,
        sc_periodic_rpt_code,
        rpt_year,
        rpt_period,
        period,
        sent_tms,
        rpt_submission_status_code
    FROM {{ ref('atm_sc_periodic_report') }}
    WHERE src_stm_code = 'SCMS_SC_FIRM_PERIODIC_REPORT'
        AND ds_rcrd_st = 'ACTIVE'
),

se_co AS (
    SELECT
        sc_id,
        sc_code,
        sc_nm
    FROM {{ ref('atm_securities_company') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}','yyyy-MM-dd')
        AND ds_rcrd_st = 'ACTIVE'
        AND src_stm_code = 'SCMS_SC_FIRM_INFO'
),

joined AS (
    SELECT
        se_co.sc_code                                                                                                     AS sc_code,
        se_co.sc_nm                                                                                                       AS sc_nm,
        sc_rpt.rpt_code                                                                                                   AS rpt_code,
        sc_pe_rpt.rpt_year                                                                                                AS rpt_year,
        sc_pe_rpt.rpt_period                                                                                              AS rpt_period_tp_code,
        sc_pe_rpt.period                                                                                                  AS period_nbr,
        CASE WHEN sc_rpt.rpt_code = 'BCTHHD_CTCK' AND sc_rpt_in_va.cell_id = 'TS017' THEN TRY_CAST(sc_rpt_in_va.cell_val AS int) END AS total_employee_cnt,
        CASE WHEN sc_rpt.rpt_code = 'BCTHHD_CTCK' AND sc_rpt_in_va.cell_id = 'TS018' THEN TRY_CAST(sc_rpt_in_va.cell_val AS int) END AS licensed_practitioner_cnt,
        CASE WHEN sc_rpt.rpt_code = 'BCTHHD_CTCK' AND sc_rpt_in_va.cell_id = 'TS107' THEN TRY_CAST(sc_rpt_in_va.cell_val AS int) END AS brokerage_practitioner_cnt,
        CASE WHEN sc_rpt.rpt_code = 'BCTHHD_CTCK' AND sc_rpt_in_va.cell_id = 'TS115' THEN TRY_CAST(sc_rpt_in_va.cell_val AS int) END AS underwriting_practitioner_cnt,
        CASE WHEN sc_rpt.rpt_code = 'BCTHHD_CTCK' AND sc_rpt_in_va.cell_id = 'TS119' THEN TRY_CAST(sc_rpt_in_va.cell_val AS int) END AS advisory_practitioner_cnt,
        CASE WHEN sc_rpt.rpt_code = 'BCTHHD_CTCK' AND sc_rpt_in_va.cell_id = 'TS111' THEN TRY_CAST(sc_rpt_in_va.cell_val AS int) END AS proprietary_practitioner_cnt,
        CASE WHEN sc_rpt.rpt_code = 'BCHDPS'      AND sc_rpt_in_va.cell_id = 'TS009' THEN TRY_CAST(sc_rpt_in_va.cell_val AS int) END AS deriv_brokerage_practitioner_cnt,
        CASE WHEN sc_rpt.rpt_code = 'BCHDPS'      AND sc_rpt_in_va.cell_id = 'TS017' THEN TRY_CAST(sc_rpt_in_va.cell_val AS int) END AS deriv_advisory_practitioner_cnt,
        CASE WHEN sc_rpt.rpt_code = 'BCHDPS'      AND sc_rpt_in_va.cell_id = 'TS013' THEN TRY_CAST(sc_rpt_in_va.cell_val AS int) END AS deriv_proprietary_practitioner_cnt,
        CAST(sc_pe_rpt.sent_tms AS date)                                                                                  AS submission_dt,
        sc_pe_rpt.rpt_submission_status_code                                                                             AS submission_status_code,
        sc_rpt_in_va.src_stm_code                                                                                         AS src_stm_code
    FROM sc_rpt_in_va
    INNER JOIN sc_rpt_in_su
        ON  sc_rpt_in_su.sc_rpt_input_submission_id = sc_rpt_in_va.sc_rpt_input_submission_id
    INNER JOIN sc_pe_rpt
        ON  sc_pe_rpt.sc_periodic_rpt_code = sc_rpt_in_su.ref_id
        AND sc_rpt_in_su.ref_tp_code = 'BAO_CAO_DINH_KY'
    INNER JOIN se_co
        ON  se_co.sc_id = sc_pe_rpt.sc_id
    INNER JOIN sc_rpt
        ON  sc_rpt.sc_rpt_id = sc_rpt_in_su.sc_rpt_id
    WHERE sc_rpt.rpt_code IN ('BCTHHD_CTCK', 'BCHDPS')
        AND sc_pe_rpt.sent_tms IS NOT NULL
),

agg AS (
    SELECT
        sc_code,
        sc_nm,
        rpt_code,
        rpt_year,
        rpt_period_tp_code,
        period_nbr,
        MAX(total_employee_cnt)                 AS total_employee_cnt,
        MAX(licensed_practitioner_cnt)          AS licensed_practitioner_cnt,
        MAX(total_employee_cnt) - MAX(licensed_practitioner_cnt) AS unlicensed_practitioner_cnt,
        MAX(brokerage_practitioner_cnt)         AS brokerage_practitioner_cnt,
        MAX(underwriting_practitioner_cnt)      AS underwriting_practitioner_cnt,
        MAX(advisory_practitioner_cnt)          AS advisory_practitioner_cnt,
        MAX(proprietary_practitioner_cnt)       AS proprietary_practitioner_cnt,
        MAX(deriv_brokerage_practitioner_cnt)   AS deriv_brokerage_practitioner_cnt,
        MAX(deriv_advisory_practitioner_cnt)    AS deriv_advisory_practitioner_cnt,
        MAX(deriv_proprietary_practitioner_cnt) AS deriv_proprietary_practitioner_cnt,
        MAX(submission_dt)                      AS submission_dt,
        MAX(submission_status_code)             AS submission_status_code,
        MAX(src_stm_code)                       AS src_stm_code,
        row_number() over (
            partition by sc_code, rpt_code, rpt_year, rpt_period_tp_code, period_nbr
            order by MAX(submission_dt) desc
        ) as rn
    FROM joined
    GROUP BY sc_code, sc_nm, rpt_code, rpt_year, rpt_period_tp_code, period_nbr
)

SELECT
    CAST({{ generate_surrogate_key_bigint('OPR_SC_PRAC_PROFILE', "concat_ws('-', agg.sc_code, agg.rpt_code, agg.rpt_year, agg.rpt_period_tp_code, agg.period_nbr)") }} AS string) AS prac_profile_id,
    CAST(sc_code AS string)                              AS sc_code,
    CAST(sc_nm AS string)                                AS sc_nm,
    CAST(rpt_code AS string)                             AS rpt_code,
    CAST(rpt_year AS int)                                AS rpt_year,
    CAST(rpt_period_tp_code AS string)                   AS rpt_period_tp_code,
    CAST(period_nbr AS int)                              AS period_nbr,
    CAST(total_employee_cnt AS int)                      AS total_employee_cnt,
    CAST(licensed_practitioner_cnt AS int)               AS licensed_practitioner_cnt,
    CAST(unlicensed_practitioner_cnt AS int)             AS unlicensed_practitioner_cnt,
    CAST(brokerage_practitioner_cnt AS int)              AS brokerage_practitioner_cnt,
    CAST(underwriting_practitioner_cnt AS int)           AS underwriting_practitioner_cnt,
    CAST(advisory_practitioner_cnt AS int)               AS advisory_practitioner_cnt,
    CAST(proprietary_practitioner_cnt AS int)            AS proprietary_practitioner_cnt,
    CAST(deriv_brokerage_practitioner_cnt AS int)        AS deriv_brokerage_practitioner_cnt,
    CAST(deriv_advisory_practitioner_cnt AS int)         AS deriv_advisory_practitioner_cnt,
    CAST(deriv_proprietary_practitioner_cnt AS int)      AS deriv_proprietary_practitioner_cnt,
    CAST(submission_dt AS date)                          AS submission_dt,
    CAST(submission_status_code AS string)               AS submission_status_code,
    CAST(src_stm_code AS string)                         AS src_stm_code
FROM agg
WHERE rn = 1
