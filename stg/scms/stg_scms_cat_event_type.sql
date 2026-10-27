/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_event_type
* Program name: Staging SCMS.CAT_EVENT_TYPE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                            AS id
    , CAST(event_type_code AS string)          AS event_type_code
    , CAST(event_type_name AS string)          AS event_type_name
    , CAST(note AS string)                     AS note
    , CAST(created_by AS int)                  AS created_by
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(record_status AS int)               AS record_status
    , CAST(requires_license AS int)            AS requires_license
    , CAST(target_entity AS string)            AS target_entity
    , CAST(requires_disclosure AS int)         AS requires_disclosure
    , CAST(obligation_type AS int)             AS obligation_type
    , CAST(event_group_id AS int)              AS event_group_id
    , CAST(cycle AS int)                       AS cycle
    , CAST(frequency AS int)                   AS frequency
    , CAST(cutoff_date AS string)              AS cutoff_date
    , CAST(submission_method AS int)           AS submission_method
    , CAST(effective_date AS date)             AS effective_date
    , CAST(expiry_date AS date)                AS expiry_date
    , CAST(updated_at AS timestamp)            AS updated_at
    , CAST(updated_by AS int)                  AS updated_by
    , CAST(event_category AS int)              AS event_category
    , CAST(deadline_calculation_method AS int) AS deadline_calculation_method
    , CAST(extended_data AS string)            AS extended_data
FROM {{ source('source_scms', 'raw_cat_event_type') }}