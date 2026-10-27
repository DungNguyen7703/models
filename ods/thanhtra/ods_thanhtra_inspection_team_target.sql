/*
*--------------------------------------------------------------------*
* Program code: ods_thanhtra_inspection_team_target
* Program name: ODS THANHTRA.INSPECTION_TEAM_TARGET
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , inspection_team_id
    , target_type
    , target_reference_id
    , target_name
    , created_at
    , last_modified_at
    , created_by
    , last_modified_by
    , version
    , deleted
    , content
    , inspection_period_from
    , inspection_period_to
    , anti_money_laundering
    , abnormal_transaction_check
    , note
FROM {{ ref('stg_thanhtra_inspection_team_target') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
        AND deleted = 0