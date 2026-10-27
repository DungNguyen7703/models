/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_service
* Program name: Staging SCMS.CAT_SERVICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                 AS id
    , CAST(service_code AS string)  AS service_code
    , CAST(service_name AS string)  AS service_name
    , CAST(note AS string)          AS note
    , CAST(created_by AS int)       AS created_by
    , CAST(created_at AS timestamp) AS created_at
    , CAST(record_status AS int)    AS record_status
FROM {{ source('source_scms', 'raw_cat_service') }}
WHERE created_at >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND created_at < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1