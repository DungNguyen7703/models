/*
*--------------------------------------------------------------------*
* Program code: ods_ids_categories
* Program name: ODS IDS.CATEGORIES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    id
    , industry_cd
    , industry_name
    , description
    , parent_id
    , active_flg
    , created_by
    , created_date
    , updated_by
    , updated_date
    , status_flg
    , id_sync
FROM {{ ref('stg_ids_categories') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')