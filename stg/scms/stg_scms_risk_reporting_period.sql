/*
*--------------------------------------------------------------------*
* Program code: stg_scms_risk_reporting_period
* Program name: Staging SCMS.RISK_REPORTING_PERIOD
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
    , CAST(period AS string)              AS period
    , CAST(report_year AS int)            AS report_year
    , CAST(consolidated AS int)           AS consolidated
    , CAST(scored AS int)                 AS scored
    , CAST(description AS string)         AS description
    , CAST(created_by AS int)             AS created_by
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_by AS int)       AS last_modified_by
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(record_status AS int)          AS record_status
    , CAST(period_value AS string)        AS period_value
FROM {{ source('source_scms', 'raw_risk_reporting_period') }}