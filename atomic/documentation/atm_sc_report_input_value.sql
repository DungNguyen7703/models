/*
*--------------------------------------------------------------------*
* Program code: atm_sc_report_input_value
* Program name: Atomic Securities Company Report Input Value
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

WITH re_in_ce_va AS (
    SELECT
        id
        , report_input_submission_id
        , sheet_id
        , section_id
        , cell_id
        , row_no
        , item_value
        , ref_type
    FROM {{ ref('ods_scms_report_input_cell_value') }}
    where data_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
)

SELECT
    {{ generate_surrogate_key_bigint('SCMS_REPORT_INPUT_CELL_VALUE', "re_in_ce_va.id") }}                           AS sc_rpt_input_val_id
    , CAST(re_in_ce_va.id AS string)                                                                                AS sc_rpt_input_val_code
    , CAST('SCMS_REPORT_INPUT_CELL_VALUE' AS string)                                                                AS src_stm_code
    , {{ generate_surrogate_key_bigint('SCMS_REPORT_INPUT_SUBMISSION', "re_in_ce_va.report_input_submission_id") }} AS sc_rpt_input_submission_id
    , CAST(re_in_ce_va.report_input_submission_id AS string)                                                        AS sc_rpt_input_submission_code
    , CAST(re_in_ce_va.sheet_id AS string)                                                                          AS sheet_id
    , CAST(re_in_ce_va.section_id AS string)                                                                        AS section_id
    , CAST(re_in_ce_va.cell_id AS string)                                                                           AS cell_id
    , CAST(re_in_ce_va.row_no AS int)                                                                               AS row_index
    , CAST(re_in_ce_va.item_value AS string)                                                                        AS cell_val
    , CAST(re_in_ce_va.ref_type AS string)                                                                          AS ref_tp_code
FROM re_in_ce_va