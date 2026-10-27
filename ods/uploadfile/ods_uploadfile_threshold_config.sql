/*
*--------------------------------------------------------------------*
* Program code: ods_uploadfile_threshold_config
* Program name: ODS UBCK.THRESHOLD_CONFIG
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
    , indicator_code
    , indicator_name
    , value_from
    , value_to
    , status
    , effective_date
    , end_date
    , record_status
    , created_at
    , createdby
    , upload_history_id
FROM {{ ref('stg_uploadfile_threshold_config') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
