/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_practitioner_business_line
* Program name: Staging SCMS.LNK_PRACTITIONER_BUSINESS_LINE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(licensed_practitioner_id AS int) AS licensed_practitioner_id
    , CAST(business_line_id AS int)         AS business_line_id
FROM {{ source('source_scms', 'raw_lnk_practitioner_business_line') }}