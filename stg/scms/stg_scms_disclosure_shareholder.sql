/*
*--------------------------------------------------------------------*
* Program code: stg_scms_disclosure_shareholder
* Program name: Staging SCMS.DISCLOSURE_SHAREHOLDER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                        AS id
    , CAST(sc_firm_info_id AS int)           AS sc_firm_info_id
    , CAST(transaction_type_id AS int)       AS transaction_type_id
    , CAST(disclosure_date AS timestamp)     AS disclosure_date
    , CAST(content AS string)                AS content
    , CAST(created_by AS int)                AS created_by
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(record_status AS int)             AS record_status
    , CAST(title AS string)                  AS title
    , CAST(summary AS string)                AS summary
    , CAST(sent_at AS timestamp)             AS sent_at
    , CAST(legacy_filename AS string)        AS legacy_filename
    , CAST(legacy_filedata AS string)        AS legacy_filedata
    , CAST(legacy_rowtext AS string)         AS legacy_rowtext
    , CAST(event_date AS timestamp)          AS event_date
    , CAST(disclosure_deadline AS timestamp) AS disclosure_deadline
    , CAST(disclosure_person_name AS string) AS disclosure_person_name
    , CAST(sender_id AS int)                 AS sender_id
    , CAST(note AS string)                   AS note
    , CAST(eform_data AS string)             AS eform_data
    , CAST(late_days AS int)                 AS late_days
    , CAST(updated_at AS timestamp)          AS updated_at
    , CAST(updated_by AS int)                AS updated_by
    , CAST(import_file_path AS string)       AS import_file_path
    , CAST(import_file_name AS string)       AS import_file_name
    , CAST(import_data AS string)            AS import_data
    , CAST(import_bm_id AS decimal(19,0))    AS import_bm_id
    , CAST(attachment_path AS string)        AS attachment_path
FROM {{ source('source_scms', 'raw_disclosure_shareholder') }}
WHERE created_at >= to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') AND created_at < to_date('{{ var("etl_date") }}', 'yyyy-MM-dd') + 1