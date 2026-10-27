-- ────────────────────────────────────────────────────────────
-- Model : qlkd_opr_individual_related_party_network_flat
-- Type  : OPERATIONAL
-- ────────────────────────────────────────────────────────────

SELECT
    -- OPERATIONAL Individual Related Party Network
    o.sc_insider_related_person_code,
    o.sc_senior_personnel_code,
    o.related_person_full_nm,
    o.rltnp,
    o.representative_position,
    o.identification_nbr,
    o.shares_count,
    o.ownership_ratio,
    o.src_stm_code

FROM {{ ref('dtm_opr_individual_related_party_network') }} o