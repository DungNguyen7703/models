/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_user_report
* Program name: Staging SCMS.LNK_USER_REPORT
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(user_id AS int)         AS user_id
    , CAST(form_report_id AS int)  AS form_report_id
    , CAST(id AS int)              AS id
    , CAST(sc_firm_info_id AS int) AS sc_firm_info_id
FROM {{ source('source_scms', 'raw_lnk_user_report') }}