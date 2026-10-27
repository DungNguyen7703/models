/*
*--------------------------------------------------------------------*
* Program code: stg_scms_lnk_sc_firm_service
* Program name: Staging SCMS.LNK_SC_FIRM_SERVICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))              AS id
    , CAST(sc_firm_info_id AS decimal(19,0)) AS sc_firm_info_id
    , CAST(service_id AS decimal(19,0))      AS service_id
    , CAST(license_number AS string)         AS license_number
    , CAST(license_date AS date)             AS license_date
    , CAST(record_status AS bigint)          AS record_status
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(start_date AS date)               AS start_date
    , CAST(end_date AS date)                 AS end_date
    , CAST(approval_file AS string)          AS approval_file
FROM {{ source('source_scms', 'raw_lnk_sc_firm_service') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') 
  AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1