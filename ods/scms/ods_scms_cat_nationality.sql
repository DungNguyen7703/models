/*
*--------------------------------------------------------------------*
* Program code: ods_scms_cat_nationality
* Program name: ODS SCMS.CAT_NATIONALITY
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Dong bo day du cot theo stg moi.
*--------------------------------------------------------------------*
*/

SELECT
    id
    , nationality_code
    , nationality_name
    , note
    , created_by
    , created_at
    , record_status
    , ecatalog_id
FROM {{ ref('stg_scms_cat_nationality') }}
WHERE created_at >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND created_at < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1