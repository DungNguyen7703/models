-- ────────────────────────────────────────────────────────────
-- Model : qlkd_opr_securities_company_personnel_profile_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Securities Company Personnel Profile
    o.sc_senior_personnel_code,
    o.sc_code,
    o.full_nm,
    o.department,
    o.position_nm,
    o.email,
    o.phone,
    o.work_start_dt,
    o.dismissal_dt,
    o.personnel_status_code,
    o.src_stm_code

FROM {{ ref('dtm_opr_securities_company_personnel_profile') }} o