/*
*--------------------------------------------------------------------*
* Program code: ods_fms_national
* Program name: ODS FMS.NATIONAL
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
    , date_created
    , created_by
    , date_modified
    , modify_by
    , sname
    , item_name
    , description
    , record_status
    , deleted
    , data_migration
FROM {{ ref('stg_fms_national') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')