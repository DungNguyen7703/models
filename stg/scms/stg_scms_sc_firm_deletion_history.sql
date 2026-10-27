/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_deletion_history
* Program name: Staging SCMS.SC_FIRM_DELETION_HISTORY
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung STG theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)               AS id
    , CAST(sc_firm_info_id AS int)  AS sc_firm_info_id
    , CAST(content AS string)       AS content
    , CAST(created_by AS int)       AS created_by
    , CAST(created_at AS timestamp) AS created_at
    , CAST(record_status AS int)    AS record_status
FROM {{ source('source_scms', 'raw_sc_firm_deletion_history') }}