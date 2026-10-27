/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_sc_firm_status_report
* Program name: Staging SCMS.LNK_SC_FIRM_STATUS_REPORT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(sc_firm_status_id AS int) AS sc_firm_status_id
    , CAST(form_report_id AS int)    AS form_report_id
    , CAST(created_at AS timestamp)  AS created_at
    , CAST(created_by AS int)        AS created_by
FROM {{ source('source_scms', 'raw_lnk_sc_firm_status_report') }}