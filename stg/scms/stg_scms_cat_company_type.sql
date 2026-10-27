/*
*--------------------------------------------------------------------*
* Program code: stg_scms_cat_company_type
* Program name: Staging SCMS.CAT_COMPANY_TYPE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS bigint)                  AS id
    , CAST(company_type_code AS string) AS company_type_code
    , CAST(company_type_name AS string) AS company_type_name
    , CAST(note AS string)              AS note
    , CAST(created_by AS bigint)        AS created_by
    , CAST(created_at AS timestamp)     AS created_at
    , CAST(record_status AS int)        AS record_status
    , CAST(joint_stock_company AS int)  AS joint_stock_company
    , CAST(ecatalog_id AS string)       AS ecatalog_id
FROM {{ source('source_scms', 'raw_cat_company_type') }}