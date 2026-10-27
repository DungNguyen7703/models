/*
*--------------------------------------------------------------------*
* Program code: stg_scms_risk_indicator
* Program name: Staging SCMS.RISK_INDICATOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                       AS id
    , CAST(indicator_code AS string)      AS indicator_code
    , CAST(indicator_name AS string)      AS indicator_name
    , CAST(weight AS decimal(6,2))        AS weight
    , CAST(description AS string)         AS description
    , CAST(implementation_method AS int)  AS implementation_method
    , CAST(created_by AS int)             AS created_by
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_by AS int)       AS last_modified_by
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(default_value AS int)          AS default_value
    , CAST(record_status AS int)          AS record_status
    , CAST(record_type AS string)         AS record_type
    , CAST(formula AS string)             AS formula
    , CAST(sum_formula AS string)         AS sum_formula
    , CAST(formula_text AS string)        AS formula_text
FROM {{ source('source_scms', 'raw_risk_indicator') }}