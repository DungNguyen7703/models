/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_shareholder_transfer
* Program name: Staging SCMS.SC_FIRM_SHAREHOLDER_TRANSFER
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
    , CAST(transferor_shareholder_id AS int) AS transferor_shareholder_id
    , CAST(transferee_shareholder_id AS int) AS transferee_shareholder_id
    , CAST(document_number AS string)        AS document_number
    , CAST(document_date AS date)            AS document_date
    , CAST(transfer_date AS timestamp)       AS transfer_date
    , CAST(transferred_shares AS int)        AS transferred_shares
    , CAST(transfer_ratio AS decimal(10,4))  AS transfer_ratio
    , CAST(attachment_path AS string)        AS attachment_path
    , CAST(note AS string)                   AS note
    , CAST(created_by AS int)                AS created_by
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(last_modified_by AS int)          AS last_modified_by
    , CAST(last_modified_at AS timestamp)    AS last_modified_at
    , CAST(record_status AS int)             AS record_status
    , CAST(event_type_id AS int)             AS event_type_id
    , CAST(deleted AS int)                   AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_shareholder_transfer') }}