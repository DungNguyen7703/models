/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_service
* Program name: Staging SCMS.SC_FIRM_SERVICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                         AS id
    , CAST(sc_firm_info_id AS int)            AS sc_firm_info_id
    , CAST(service_catalog_id AS int)         AS service_catalog_id
    , CAST(registration_doc_number AS string) AS registration_doc_number
    , CAST(registration_date AS date)         AS registration_date
    , CAST(termination_doc_number AS string)  AS termination_doc_number
    , CAST(end_date AS date)                  AS end_date
    , CAST(valid_dossier_date AS date)        AS valid_dossier_date
    , CAST(note AS string)                    AS note
    , CAST(created_by AS int)                 AS created_by
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(last_modified_by AS int)           AS last_modified_by
    , CAST(last_modified_at AS timestamp)     AS last_modified_at
    , CAST(record_status AS int)              AS record_status
    , CAST(provisional AS int)                AS provisional
    , CAST(attachment_path AS string)         AS attachment_path
    , CAST(service_id AS int)                 AS service_id
    , CAST(effective_date AS date)            AS effective_date
    , CAST(document_number AS string)         AS document_number
FROM {{ source('source_scms', 'raw_sc_firm_service') }}