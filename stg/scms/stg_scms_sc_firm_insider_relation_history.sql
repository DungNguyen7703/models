/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_insider_relation_history
* Program name: Staging SCMS.SC_FIRM_INSIDER_RELATION_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                  AS id
    , CAST(change_type AS string)      AS change_type
    , CAST(recorded_at AS timestamp)   AS recorded_at
    , CAST(insider_relation_id AS int) AS insider_relation_id
    , CAST(content AS string)          AS content
FROM {{ source('source_scms', 'raw_sc_firm_insider_relation_history') }}