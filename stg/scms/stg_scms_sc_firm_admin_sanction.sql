/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_admin_sanction
* Program name: Staging SCMS.SC_FIRM_ADMIN_SANCTION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                       AS id
    , CAST(sc_firm_info_id AS int)          AS sc_firm_info_id
    , CAST(form_type AS string)             AS form_type
    , CAST(content AS string)               AS content
    , CAST(amount AS int)                   AS amount
    , CAST(additional_penalty AS string)    AS additional_penalty
    , CAST(additional_penalty_date AS date) AS additional_penalty_date
    , CAST(decision_content AS string)      AS decision_content
    , CAST(decision_date AS date)           AS decision_date
    , CAST(created_by AS int)               AS created_by
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(last_modified_by AS int)         AS last_modified_by
    , CAST(last_modified_at AS timestamp)   AS last_modified_at
    , CAST(record_status AS int)            AS record_status
    , CAST(attachment_path AS string)       AS attachment_path
    , CAST(processing_unit AS string)       AS processing_unit
    , CAST(remedial_measure AS string)      AS remedial_measure
FROM {{ source('source_scms', 'raw_sc_firm_admin_sanction') }}