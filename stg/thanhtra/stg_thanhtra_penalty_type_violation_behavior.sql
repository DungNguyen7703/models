/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_penalty_type_violation_behavior
* Program name: Staging THANHTRA.PENALTY_TYPE_VIOLATION_BEHAVIOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                      AS id
    , CAST(penalty_type_id AS string)       AS penalty_type_id
    , CAST(violation_behavior_id AS string) AS violation_behavior_id
    , CAST(created_at AS date)              AS created_at
    , CAST(last_modified_at AS date)        AS last_modified_at
    , CAST(created_by AS string)            AS created_by
    , CAST(last_modified_by AS string)      AS last_modified_by
    , CAST(version AS bigint)               AS version
    , CAST(deleted AS int)                  AS deleted
FROM {{ source('source_thanhtra', 'raw_penalty_type_violation_behavior') }}