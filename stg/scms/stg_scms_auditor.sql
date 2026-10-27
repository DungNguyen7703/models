/*
*--------------------------------------------------------------------*
* Program code: stg_scms_auditor
* Program name: Staging SCMS.AUDITOR
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                          AS id
    , CAST(audit_firm_id AS int)             AS audit_firm_id
    , CAST(full_name AS string)              AS full_name
    , CAST(certificate_number AS string)     AS certificate_number
    , CAST(issue_date AS timestamp)          AS issue_date
    , CAST(approval_date AS date)            AS approval_date
    , CAST(approval_revocation_date AS date) AS approval_revocation_date
    , CAST(note AS string)                   AS note
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(last_modified_at AS timestamp)    AS last_modified_at
    , CAST(record_status AS int)             AS record_status
FROM {{ source('source_scms', 'raw_auditor') }}