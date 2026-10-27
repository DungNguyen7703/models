/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_report_templates
* Program name: Staging NHNCK.REPORT_TEMPLATES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)            AS id
    , CAST(module_id AS string)   AS module_id
    , CAST(report_code AS string) AS report_code
    , CAST(report_name AS string) AS report_name
    , CAST(template_json AS string) AS template_json
    , CAST(query_config AS string)  AS query_config
    , CAST(status AS int)         AS status
    , CAST(created_at AS date)    AS created_at
    , CAST(created_by AS string)  AS created_by
FROM {{ source('source_nhnck', 'raw_report_templates') }}
