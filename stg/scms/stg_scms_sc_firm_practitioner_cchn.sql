/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_practitioner_cchn
* Program name: Staging SCMS.SC_FIRM_PRACTITIONER_CCHN
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                           AS id
    , CAST(practitioner_id AS int)              AS practitioner_id
    , CAST(securities_license_number AS string) AS securities_license_number
    , CAST(securities_license_date AS date)     AS securities_license_date
    , CAST(business_division_id AS int)         AS business_division_id
    , CAST(responsible_service_id AS int)       AS responsible_service_id
    , CAST(sort_order AS int)                   AS sort_order
    , CAST(created_at AS timestamp)             AS created_at
FROM {{ source('source_scms', 'raw_sc_firm_practitioner_cchn') }}