-- ────────────────────────────────────────────────────────────
-- Model : qlkd_opr_individual_listed_company_role_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Individual Listed Company Role
    o.sc_insider_related_person_code,
    o.sc_senior_personnel_code,
    o.sc_code,
    o.representative_position,
    o.shares_count,
    o.src_stm_code

FROM {{ ref('dtm_opr_individual_listed_company_role') }} o