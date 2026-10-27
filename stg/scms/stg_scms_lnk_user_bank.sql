/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_user_bank
* Program name: Staging SCMS.LNK_USER_BANK
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)      AS id
    , CAST(user_id AS int) AS user_id
    , CAST(bank_id AS int) AS bank_id
FROM {{ source('source_scms', 'raw_lnk_user_bank') }}