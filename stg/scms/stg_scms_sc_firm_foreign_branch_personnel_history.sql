/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_foreign_branch_personnel_history
* Program name: Staging SCMS.SC_FIRM_FOREIGN_BRANCH_PERSONNEL_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                        AS id
    , CAST(sc_firm_foreign_branch_id AS int) AS sc_firm_foreign_branch_id
    , CAST(performer_name AS string)         AS performer_name
    , CAST(personnel_id AS int)              AS personnel_id
    , CAST(content AS string)                AS content
    , CAST(action AS string)                 AS action
    , CAST(performed_at AS timestamp)        AS performed_at
FROM {{ source('source_scms', 'raw_sc_firm_foreign_branch_personnel_history') }}