/*
*--------------------------------------------------------------------*
* Program code: stg_scms_digital_certificate
* Program name: Staging SCMS.DIGITAL_CERTIFICATE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                            AS id
    , CAST(user_id AS int)                       AS user_id
    , CAST(username AS string)                   AS username
    , CAST(key_data AS string)                   AS key_data
    , CAST(serial AS string)                     AS serial
    , CAST(subject AS string)                    AS subject
    , CAST(issuer AS string)                     AS issuer
    , CAST(individual AS int)                    AS individual
    , CAST(created_by AS int)                    AS created_by
    , CAST(created_at AS timestamp)              AS created_at
    , CAST(last_modified_by AS int)              AS last_modified_by
    , CAST(last_modified_at AS timestamp)        AS last_modified_at
    , CAST(record_status AS int)                 AS record_status
    , CAST(sc_firm_info_id AS int)               AS sc_firm_info_id
    , CAST(certificate_file_path AS string)      AS certificate_file_path
    , CAST(note AS string)                       AS note
    , CAST(purpose AS string)                    AS purpose
    , CAST(issue_date AS date)                   AS issue_date
    , CAST(expiry_date AS date)                  AS expiry_date
    , CAST(last_modified_at_legacy AS timestamp) AS last_modified_at_legacy
    , CAST(last_modified_by_legacy AS int)       AS last_modified_by_legacy
    , CAST(serial_number AS string)              AS serial_number
    , CAST(subject_name AS string)               AS subject_name
    , CAST(issuing_organization AS string)       AS issuing_organization
FROM {{ source('source_scms', 'raw_digital_certificate') }}