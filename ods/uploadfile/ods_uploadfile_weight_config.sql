/*
*--------------------------------------------------------------------*
* Program code: ods_uploadfile_weight_config
* Program name: ODS UBCK.WEIGHT_CONFIG
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
    , output_indicator_code
    , input_indicator_code
    , input_indicator_name
    , weight
    , effective_date
    , end_date
    , record_status
    , created_at
    , createdby
    , upload_history_id
FROM {{ ref('stg_uploadfile_weight_config') }}
WHERE ds_snpst_dt = to_date('{{ var("etl_date") }}', 'yyyy-MM-dd')
