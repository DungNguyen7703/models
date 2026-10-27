/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_violation_record_behavior
* Program name: Staging THANHTRA.VIOLATION_RECORD_BEHAVIOR
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
    , CAST(violation_record_id AS string)   AS violation_record_id
    , CAST(violation_behavior_id AS string) AS violation_behavior_id
    , CAST(description AS string)           AS description
    , CAST(created_at AS date)              AS created_at
    , CAST(last_modified_at AS date)        AS last_modified_at
    , CAST(created_by AS string)            AS created_by
    , CAST(last_modified_by AS string)      AS last_modified_by
    , CAST(version AS bigint)               AS version
    , CAST(deleted AS int)                  AS deleted
    , CAST(legal_basis AS string)           AS legal_basis
FROM {{ source('source_thanhtra', 'raw_violation_record_behavior') }}