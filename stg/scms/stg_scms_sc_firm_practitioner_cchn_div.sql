/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_practitioner_cchn_div
* Program name: Staging SCMS.SC_FIRM_PRACTITIONER_CCHN_DIV
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                   AS id
    , CAST(cchn_id AS int)              AS cchn_id
    , CAST(business_division_id AS int) AS business_division_id
    , CAST(sort_order AS int)           AS sort_order
FROM {{ source('source_scms', 'raw_sc_firm_practitioner_cchn_div') }}