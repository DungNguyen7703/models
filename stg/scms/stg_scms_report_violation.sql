/*
*--------------------------------------------------------------------*
* Program code: stg_scms_report_violation
* Program name: Staging SCMS.REPORT_VIOLATION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                  AS id
    , CAST(sc_firm_info_id AS int)   AS sc_firm_info_id
    , CAST(reason AS string)         AS reason
    , CAST(violation_date AS date)   AS violation_date
    , CAST(user_id AS int)           AS user_id
    , CAST(last_modified_at AS date) AS last_modified_at
FROM {{ source('source_scms', 'raw_report_violation') }}