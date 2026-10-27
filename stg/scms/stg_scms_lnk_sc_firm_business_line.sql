/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_sc_firm_business_line
* Program name: Staging SCMS.LNK_SC_FIRM_BUSINESS_LINE
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(sc_firm_id AS int)       AS sc_firm_id
    , CAST(business_line_id AS int) AS business_line_id
    , CAST(record_status AS int)    AS record_status
    , CAST(id AS int)               AS id
FROM {{ source('source_scms', 'raw_lnk_sc_firm_business_line') }}