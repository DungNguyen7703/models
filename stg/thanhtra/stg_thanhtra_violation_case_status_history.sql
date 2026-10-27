/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_violation_case_status_history
* Program name: Staging THANHTRA.VIOLATION_CASE_STATUS_HISTORY
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
    , CAST(violation_case_id AS string) AS violation_case_id
    , CAST(from_status AS string)       AS from_status
    , CAST(to_status AS string)         AS to_status
    , CAST(changed_by AS string)        AS changed_by
    , CAST(changed_at AS date)          AS changed_at
    , CAST(note AS string)              AS note
    , CAST(created_at AS date)          AS created_at
    , CAST(last_modified_at AS date)    AS last_modified_at
    , CAST(created_by AS string)        AS created_by
    , CAST(last_modified_by AS string)  AS last_modified_by
    , CAST(version AS bigint)           AS version
    , CAST(deleted AS int)              AS deleted
FROM {{ source('source_thanhtra', 'raw_violation_case_status_history') }}