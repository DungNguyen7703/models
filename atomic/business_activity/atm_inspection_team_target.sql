/*
*--------------------------------------------------------------------*
* Program code: atm_inspection_team_target
* Program name: Atomic Inspection Team Target
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH in_te_ta AS (
    SELECT
        id
        , inspection_team_id
        , target_type
        , target_reference_id
        , target_name
        , inspection_period_from
        , inspection_period_to
        , anti_money_laundering
        , abnormal_transaction_check
        , content
        , note
    FROM {{ ref('ods_thanhtra_inspection_team_target') }}
),

in_te AS (
    SELECT
        id
        , code
    FROM {{ ref('ods_thanhtra_inspection_team') }}
)

SELECT
    {{ generate_surrogate_key_bigint('THANHTRA_INSPECTION_TEAM_TARGET', "in_te_ta.id") }}                        AS inspection_team_target_id
    , CAST(in_te_ta.id AS string)                                                                                AS inspection_team_target_code
    , CAST('THANHTRA_INSPECTION_TEAM_TARGET' AS string)                                                          AS src_stm_code
    , {{ generate_surrogate_key_bigint('THANHTRA_INSPECTION_TEAM', "in_te.code") }}       AS inspection_team_id
    , CAST(in_te.code AS string)                                                                                 AS inspection_team_code
    , CAST(in_te_ta.target_type AS string)                                                                       AS target_tp_code
    , CAST(in_te_ta.target_reference_id AS string)                                                               AS target_reference_id
    , CAST(in_te_ta.target_name AS string)                                                                       AS target_nm
    , CAST(in_te_ta.inspection_period_from AS date)                                                              AS inspection_period_from_dt
    , CAST(in_te_ta.inspection_period_to AS date)                                                                AS inspection_period_to_dt
    , CAST(in_te_ta.anti_money_laundering AS string)                                                             AS anti_money_laundering_indicator
    , CAST(in_te_ta.abnormal_transaction_check AS string)                                                        AS abnormal_transaction_check_indicator
    , CAST(in_te_ta.content AS string)                                                                           AS content
    , CAST(in_te_ta.note AS string)                                                                              AS note
FROM in_te_ta
INNER JOIN in_te
    ON in_te.id = in_te_ta.inspection_team_id