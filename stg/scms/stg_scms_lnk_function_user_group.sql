/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_function_user_group
* Program name: Staging SCMS.LNK_FUNCTION_USER_GROUP
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(function_id AS int)        AS function_id
    , CAST(user_group_id AS int)      AS user_group_id
    , CAST(function_action AS string) AS function_action
FROM {{ source('source_scms', 'raw_lnk_function_user_group') }}