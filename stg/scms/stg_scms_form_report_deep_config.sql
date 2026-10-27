/*
*--------------------------------------------------------------------*
* Program code: stg_scms_form_report_deep_config
* Program name: Staging SCMS.FORM_REPORT_DEEP_CONFIG
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                               AS id
    , CAST(form_report_id AS int)                 AS form_report_id
    , CAST(eform_schema_json AS string)           AS eform_schema_json
    , CAST(excel_config_json AS string)           AS excel_config_json
    , CAST(sheets_json AS string)                 AS sheets_json
    , CAST(created_at AS timestamp)               AS created_at
    , CAST(last_modified_at AS timestamp)         AS last_modified_at
    , CAST(eform_runtime_manifest_json AS string) AS eform_runtime_manifest_json
FROM {{ source('source_scms', 'raw_form_report_deep_config') }}