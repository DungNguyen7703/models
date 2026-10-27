/*
*--------------------------------------------------------------------*
* Program code: stg_scms_risk_scoring_scale
* Program name: Staging SCMS.RISK_SCORING_SCALE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                     AS id
    , CAST(risk_indicator_id AS int)    AS risk_indicator_id
    , CAST(from_value AS decimal(18,2)) AS from_value
    , CAST(to_value AS decimal(18,2))   AS to_value
    , CAST(item_value AS string)        AS item_value
    , CAST(score AS decimal(18,2))      AS score
    , CAST(note AS string)              AS note
    , CAST(created_by AS int)           AS created_by
    , CAST(created_at AS date)          AS created_at
    , CAST(last_modified_by AS int)     AS last_modified_by
    , CAST(last_modified_at AS date)    AS last_modified_at
    , CAST(record_status AS int)        AS record_status
    , CAST(value_condition AS string)   AS value_condition
FROM {{ source('source_scms', 'raw_risk_scoring_scale') }}