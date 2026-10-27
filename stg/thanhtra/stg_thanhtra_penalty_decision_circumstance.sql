/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_penalty_decision_circumstance
* Program name: Staging THANHTRA.PENALTY_DECISION_CIRCUMSTANCE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                  AS id
    , CAST(circumstance_type AS string) AS circumstance_type
    , CAST(created_at AS date)          AS created_at
    , CAST(last_modified_at AS date)    AS last_modified_at
    , CAST(created_by AS string)        AS created_by
    , CAST(last_modified_by AS string)  AS last_modified_by
    , CAST(version AS bigint)           AS version
    , CAST(deleted AS int)              AS deleted
    , CAST(content AS string)           AS content
    , CAST(penalty_decision_subject_behavior_id AS string) AS penalty_decision_subject_behavior_id
FROM {{ source('source_thanhtra', 'raw_penalty_decision_circumstance') }}