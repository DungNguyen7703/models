/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_penalty_decision_approval_history
* Program name: Staging THANHTRA.PENALTY_DECISION_APPROVAL_HISTORY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                    AS id
    , CAST(penalty_decision_id AS string) AS penalty_decision_id
    , CAST(action AS string)              AS action
    , CAST(performed_by AS string)        AS performed_by
    , CAST(performed_at AS date)          AS performed_at
    , CAST(rejection_reason AS string)    AS rejection_reason
    , CAST(note AS string)                AS note
    , CAST(created_at AS date)            AS created_at
    , CAST(last_modified_at AS date)      AS last_modified_at
    , CAST(created_by AS string)          AS created_by
    , CAST(last_modified_by AS string)    AS last_modified_by
    , CAST(version AS bigint)             AS version
    , CAST(deleted AS int)                AS deleted
    , CAST(assignee_name AS string)       AS assignee_name
FROM {{ source('source_thanhtra', 'raw_penalty_decision_approval_history') }}