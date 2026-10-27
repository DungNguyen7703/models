/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_shareholder_ownership_change
* Program name: Staging SCMS.SC_FIRM_SHAREHOLDER_OWNERSHIP_CHANGE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                       AS id
    , CAST(sc_firm_info_id AS int)          AS sc_firm_info_id
    , CAST(shareholder_id AS int)           AS shareholder_id
    , CAST(capital_before AS decimal(22,4)) AS capital_before
    , CAST(ratio_before AS decimal(12,4))   AS ratio_before
    , CAST(capital_after AS decimal(22,4))  AS capital_after
    , CAST(ratio_after AS decimal(12,4))    AS ratio_after
    , CAST(transaction_type AS string)      AS transaction_type
    , CAST(document_number AS string)       AS document_number
    , CAST(effective_date AS date)          AS effective_date
    , CAST(attachment_path AS string)       AS attachment_path
    , CAST(data_source AS string)           AS data_source
    , CAST(note AS string)                  AS note
    , CAST(created_by AS int)               AS created_by
    , CAST(created_at AS timestamp)         AS created_at
    , CAST(deleted AS int)                  AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_shareholder_ownership_change') }}
WHERE date_format(created_at, 'yyyy-MM-dd') >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND date_format(created_at, 'yyyy-MM-dd') < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1