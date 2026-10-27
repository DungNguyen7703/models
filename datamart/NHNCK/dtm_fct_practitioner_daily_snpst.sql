/*
*--------------------------------------------------------------------*
* Program code: dtm_fct_practitioner_daily_snpst
* Program name: Dtm Fct Practitioner Daily Snpst
* Created by: 
* Created date: 
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-09-04		duc.luxuan			Bổ sung cột first_license_dt (ngày cấp chứng chỉ đầu tiên của NHN) qua join atm_sp_license_certificate_document
* 2026-09-11		nam.tranhoai		Chỉ coi là vi phạm (has_active_violation='Y') khi Violation có Decision
*                                       đính kèm (JOIN atm_sp_license_decision_document); nếu chỉ có bản ghi
*                                       Violation mà chưa có Decision thì mới là mức đánh giá ban đầu, chưa
*                                       được coi là vi phạm. violation_record_dt đổi sang lấy từ
*                                       Decisions.signed_date (decision_signed_dt) thay vì Violations.created_at
* 2026-09-12		nguyet.do			age coalesce theo birth_dt, fallback birth_year khi birth_dt NULL
*                                       (dim đã pass-through birth_year từ atomic)
*--------------------------------------------------------------------*
*/

WITH violations AS (
    SELECT
        sp_conduct_violation_code,
        sp_code,
        sp_license_decision_document_id
    FROM {{ ref('atm_sp_conduct_violation') }}_hstr
    WHERE ds_snpst_dt  = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
      AND ds_rcrd_st   = 'ACTIVE'
      AND src_stm_code = 'NHNCK_VIOLATIONS'
),

decisions AS (
    SELECT
        sp_license_decision_document_id,
        decision_signed_dt
    FROM {{ ref('atm_sp_license_decision_document') }}_hstr
    WHERE ds_snpst_dt  = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
      AND ds_rcrd_st   = 'ACTIVE'
      AND src_stm_code = 'NHNCK_DECISIONS'
),

practitioner AS (
    SELECT
        securities_practitioner_dim_id,
        practitioner_code,
        birth_dt,
        birth_year
    FROM {{ ref('dtm_securities_practitioner_dim') }}_hstr
    WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
      AND ds_rcrd_st  = 'ACTIVE'
      AND src_stm_code = 'NHNCK_PROFESSIONALS'
),

certificates AS (
    SELECT
        sp_code,
        MIN(issue_dt) AS first_license_issue_dt
    FROM {{ ref('atm_sp_license_certificate_document') }}_hstr
    WHERE ds_snpst_dt  = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
      AND ds_rcrd_st   = 'ACTIVE'
      AND src_stm_code = 'NHNCK_CERTIFICATE_RECORDS'
    GROUP BY sp_code
),

confirmed_violations AS (
    SELECT
        violations.sp_conduct_violation_code,
        violations.sp_code,
        decisions.decision_signed_dt
    FROM violations 
    INNER JOIN decisions 
        ON  decisions.sp_license_decision_document_id = violations.sp_license_decision_document_id
)

SELECT
    CAST(practitioner.securities_practitioner_dim_id AS string)                                        AS practitioner_dim_id,
    date_format(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd'), 'yyyyMMdd')                            AS snpst_dt_dim_id,
    CAST(YEAR(to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')) - COALESCE(YEAR(practitioner.birth_dt), practitioner.birth_year) AS int) AS age,
    CAST(CASE WHEN confirmed_violations.sp_conduct_violation_code IS NOT NULL THEN 'Y' 
              ELSE 'N' END AS string)                                                                  AS has_active_violation,
    CAST(confirmed_violations.decision_signed_dt AS date)                                              AS violation_record_dt,
    CAST(certificates.first_license_issue_dt AS date)                                                  AS first_license_dt
FROM practitioner
LEFT JOIN confirmed_violations
    ON confirmed_violations.sp_code = practitioner.practitioner_code
LEFT JOIN certificates
    ON certificates.sp_code = practitioner.practitioner_code

