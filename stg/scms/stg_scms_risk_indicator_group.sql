/*
*--------------------------------------------------------------------*
* Program code: stg_scms_risk_indicator_group
* Program name: Staging SCMS.RISK_INDICATOR_GROUP
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
    , CAST(group_code AS string)          AS group_code
    , CAST(group_name AS string)          AS group_name
    , CAST(weight AS decimal(6,2))        AS weight
    , CAST(description AS string)         AS description
    , CAST(created_by AS int)             AS created_by
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_by AS int)       AS last_modified_by
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(record_status AS int)          AS record_status
    , CAST(record_type AS string)         AS record_type
FROM {{ source('source_scms', 'raw_risk_indicator_group') }}