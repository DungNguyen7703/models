/*
*--------------------------------------------------------------------*
* Program code: stg_scms_audit_firm
* Program name: Staging SCMS.AUDIT_FIRM
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                            AS id
    , CAST(code AS string)                     AS code
    , CAST(short_name AS string)               AS short_name
    , CAST(name_vi AS string)                  AS name_vi
    , CAST(name_en AS string)                  AS name_en
    , CAST(address AS string)                  AS address
    , CAST(phone AS string)                    AS phone
    , CAST(fax AS string)                      AS fax
    , CAST(email AS string)                    AS email
    , CAST(website AS string)                  AS website
    , CAST(charter_capital AS int)             AS charter_capital
    , CAST(business_license_number AS string)  AS business_license_number
    , CAST(business_license_date AS timestamp) AS business_license_date
    , CAST(business_license_issuer AS string)  AS business_license_issuer
    , CAST(decision_number AS string)          AS decision_number
    , CAST(note AS string)                     AS note
    , CAST(created_by AS int)                  AS created_by
    , CAST(created_at AS timestamp)            AS created_at
    , CAST(last_modified_by AS int)            AS last_modified_by
    , CAST(last_modified_at AS timestamp)      AS last_modified_at
    , CAST(record_status AS int)               AS record_status
FROM {{ source('source_scms', 'raw_audit_firm') }}