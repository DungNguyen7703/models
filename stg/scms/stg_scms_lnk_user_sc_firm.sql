/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_user_sc_firm
* Program name: Staging SCMS.LNK_USER_SC_FIRM
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(user_id AS int)    AS user_id
    , CAST(sc_firm_id AS int) AS sc_firm_id
FROM {{ source('source_scms', 'raw_lnk_user_sc_firm') }}