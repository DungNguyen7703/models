/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_inspection_team_target
* Program name: Staging THANHTRA.INSPECTION_TEAM_TARGET
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                        AS id
    , CAST(inspection_team_id AS string)      AS inspection_team_id
    , CAST(target_type AS string)             AS target_type
    , CAST(target_reference_id AS string)     AS target_reference_id
    , CAST(target_name AS string)             AS target_name
    , CAST(created_at AS date)                AS created_at
    , CAST(last_modified_at AS date)          AS last_modified_at
    , CAST(created_by AS string)              AS created_by
    , CAST(last_modified_by AS string)        AS last_modified_by
    , CAST(version AS bigint)                 AS version
    , CAST(deleted AS int)                    AS deleted
    , CAST(content AS string)                 AS content
    , CAST(inspection_period_from AS date)    AS inspection_period_from
    , CAST(inspection_period_to AS date)      AS inspection_period_to
    , CAST(anti_money_laundering AS int)      AS anti_money_laundering
    , CAST(abnormal_transaction_check AS int) AS abnormal_transaction_check
    , CAST(note AS string)                    AS note
FROM {{ source('source_thanhtra', 'raw_inspection_team_target') }}