/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_inspection_annual_plan_target
* Program name: Staging THANHTRA.INSPECTION_ANNUAL_PLAN_TARGET
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                          AS id
    , CAST(inspection_annual_plan_id AS string) AS inspection_annual_plan_id
    , CAST(target_type AS string)               AS target_type
    , CAST(target_reference_id AS string)       AS target_reference_id
    , CAST(target_name AS string)               AS target_name
    , CAST(target_code AS string)               AS target_code
    , CAST(target_source AS string)             AS target_source
    , CAST(planned_quarter AS int)              AS planned_quarter
    , CAST(planned_content AS string)           AS planned_content
    , CAST(created_at AS date)                  AS created_at
    , CAST(last_modified_at AS date)            AS last_modified_at
    , CAST(created_by AS string)                AS created_by
    , CAST(last_modified_by AS string)          AS last_modified_by
    , CAST(version AS bigint)                   AS version
    , CAST(deleted AS int)                      AS deleted
FROM {{ source('source_thanhtra', 'raw_inspection_annual_plan_target') }}