/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_transaction_office_service
* Program name: Staging SCMS.LNK_TRANSACTION_OFFICE_SERVICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                              AS id
    , CAST(sc_firm_transaction_office_id AS bigint) AS sc_firm_transaction_office_id
    , CAST(service_id AS bigint)                    AS service_id
    , CAST(created_at AS timestamp)                 AS created_at
    , CAST(record_status AS bigint)                 AS record_status
FROM {{ source('source_scms', 'raw_lnk_transaction_office_service') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') 
  AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1