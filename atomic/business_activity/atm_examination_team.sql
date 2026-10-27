/*
*--------------------------------------------------------------------*
* Program code: atm_examination_team
* Program name: Atomic Examination Team
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH ex_te AS (
    SELECT
        code
        , examination_annual_plan_id
        , unit_name
        , plan_year
        , form_type
        , start_date
        , end_date
        , duration_days
        , decision_number
        , decision_date
        , decision_name
        , announcement_date
        , content
        , examination_period_from
        , examination_period_to
        , anti_money_laundering
        , abnormal_transaction_check
        , note
    FROM {{ ref('ods_thanhtra_examination_team') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_EXAMINATION_TEAM', "ex_te.code") }}                                AS examination_team_id
    , CAST(ex_te.code AS string)                                                                                  AS examination_team_code
    , CAST('THANHTRA_EXAMINATION_TEAM' AS string)                                                                 AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_EXAMINATION_ANNUAL_PLAN', "ex_te.examination_annual_plan_id") }} AS examination_annual_plan_id
    , CAST(ex_te.examination_annual_plan_id AS string)                                                            AS examination_annual_plan_code
    , CAST(ex_te.unit_name AS string)                                                                             AS unit_nm
    , CAST(ex_te.plan_year AS int)                                                                                AS plan_year
    , CAST(ex_te.form_type AS string)                                                                             AS form_tp_code
    , CAST(ex_te.start_date AS date)                                                                              AS start_dt
    , CAST(ex_te.end_date AS date)                                                                                AS end_dt
    , CAST(ex_te.duration_days AS int)                                                                            AS duration_days
    , CAST(ex_te.decision_number AS string)                                                                       AS decision_nbr
    , CAST(ex_te.decision_date AS date)                                                                           AS decision_dt
    , CAST(ex_te.decision_name AS string)                                                                         AS decision_nm
    , CAST(ex_te.announcement_date AS date)                                                                       AS announcement_dt
    , CAST(ex_te.content AS string)                                                                               AS content
    , CAST(ex_te.examination_period_from AS date)                                                                 AS examination_period_from_dt
    , CAST(ex_te.examination_period_to AS date)                                                                   AS examination_period_to_dt
    , CAST(ex_te.anti_money_laundering AS string)                                                                 AS anti_money_laundering_indicator
    , CAST(ex_te.abnormal_transaction_check AS string)                                                            AS abnormal_transaction_check_indicator
    , CAST(ex_te.note AS string)                                                                                  AS note
FROM ex_te