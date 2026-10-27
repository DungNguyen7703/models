-- ────────────────────────────────────────────────────────────
-- Model : qlkd_opr_securities_company_practitioner_profile_flat
-- Type  : OPERATIONAL
-- [SUA 2026-10-24] Bo sung cot rpt_code, rpt_period_tp_code,
-- submission_status_code bi thieu so voi model nguon/DDL ClickHouse/raw
-- populate script (02_populate_qlkd_flat_tables.sql).
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPR_SECURITIES_COMPANY_PRACTITIONER_PROFILE
    f.prac_profile_id,
    f.sc_code,
    f.sc_nm,
    f.rpt_code,
    f.rpt_year,
    f.rpt_period_tp_code,
    f.period_nbr,
    f.total_employee_cnt,
    f.licensed_practitioner_cnt,
    f.unlicensed_practitioner_cnt,
    f.brokerage_practitioner_cnt,
    f.underwriting_practitioner_cnt,
    f.advisory_practitioner_cnt,
    f.proprietary_practitioner_cnt,
    f.deriv_brokerage_practitioner_cnt,
    f.deriv_advisory_practitioner_cnt,
    f.deriv_proprietary_practitioner_cnt,
    f.submission_dt,
    f.submission_status_code,
    f.src_stm_code

FROM {{ ref('dtm_opr_securities_company_practitioner_profile') }} f