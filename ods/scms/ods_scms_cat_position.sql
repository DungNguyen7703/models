/*
*--------------------------------------------------------------------*
* Program code: ods_scms_cat_position
* Program name: ODS SCMS.CAT_POSITION
* Created by: tuan.nguyenvanb
* Created date: 2026-10-18
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		[MOI] Bo sung ODS theo LLD SCMS.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , position_group
    , position_code
    , position_name
    , note
    , created_by
    , created_at
    , record_status
    , representative
    , board_member
    , branch_director
    , ecatalog_id
FROM {{ ref('stg_scms_cat_position') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')