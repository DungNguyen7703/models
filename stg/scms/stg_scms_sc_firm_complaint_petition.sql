/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_complaint_petition
* Program name: Staging SCMS.SC_FIRM_COMPLAINT_PETITION
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
    , CAST(sc_firm_info_id AS int)        AS sc_firm_info_id
    , CAST(processing_unit AS string)     AS processing_unit
    , CAST(petition_type AS string)       AS petition_type
    , CAST(case_code AS string)           AS case_code
    , CAST(last_modified_at AS timestamp) AS last_modified_at
    , CAST(sync_date AS timestamp)        AS sync_date
    , CAST(received_date AS date)         AS received_date
    , CAST(created_at AS timestamp)       AS created_at
    , CAST(last_modified_by AS int)       AS last_modified_by
    , CAST(created_by AS int)             AS created_by
    , CAST(data_source AS string)         AS data_source
    , CAST(summary AS string)             AS summary
    , CAST(petition_number AS string)     AS petition_number
    , CAST(sc_firm_name AS string)        AS sc_firm_name
    , CAST(sender_info_json AS string)    AS sender_info_json
    , CAST(processing_status AS string)   AS processing_status
FROM {{ source('source_scms', 'raw_sc_firm_complaint_petition') }}