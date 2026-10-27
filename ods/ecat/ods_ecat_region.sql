/*
*--------------------------------------------------------------------*
* Program code: ods_ecat_region
* Program name: ODS ECAT.REGION
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
    , code
    , name
    , country_id
    , active
    , active_reason
    , deleted
    , version
    , effective_start_date
    , effective_end_date
    , old_id
    , created_at
    , updated_at
    , created_by_id
    , created_by_name
    , updated_by_id
    , updated_by_name
    , stable_id
    , country_version_id
    , deleted_reason
FROM {{ ref('stg_ecat_region') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')