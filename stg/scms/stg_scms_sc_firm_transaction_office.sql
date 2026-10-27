/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_transaction_office
* Program name: Staging SCMS.SC_FIRM_TRANSACTION_OFFICE
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
    , CAST(sc_firm_branch_id AS int)          AS sc_firm_branch_id
    , CAST(full_name AS string)               AS full_name
    , CAST(address AS string)                 AS address
    , CAST(province_id AS int)                AS province_id
    , CAST(district_name AS string)           AS district_name
    , CAST(ward_name AS string)               AS ward_name
    , CAST(phone AS string)                   AS phone
    , CAST(fax AS string)                     AS fax
    , CAST(decision_number AS string)         AS decision_number
    , CAST(decision_date AS date)             AS decision_date
    , CAST(valid_dossier_date AS timestamp)   AS valid_dossier_date
    , CAST(representative_name AS string)     AS representative_name
    , CAST(transaction_office_status AS int)  AS transaction_office_status
    , CAST(note AS string)                    AS note
    , CAST(created_by AS int)                 AS created_by
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(last_modified_by_alt AS int)       AS last_modified_by_alt
    , CAST(last_modified_at_alt AS timestamp) AS last_modified_at_alt
    , CAST(record_status AS int)              AS record_status
    , CAST(provisional AS int)                AS provisional
    , CAST(sc_firm_transaction_id AS int)     AS sc_firm_transaction_id
    , CAST(district_id AS int)                AS district_id
    , CAST(ward_id AS int)                    AS ward_id
    , CAST(representative_id AS int)          AS representative_id
    , CAST(document_declaration AS int)       AS document_declaration
    , CAST(event_type_id AS int)              AS event_type_id
    , CAST(attachment_path AS string)         AS attachment_path
    , CAST(document_file_path AS string)      AS document_file_path
    , CAST(official_operation_date AS date)   AS official_operation_date
    , CAST(validity_end_date AS date)         AS validity_end_date
    , CAST(validity_start_date AS date)       AS validity_start_date
    , CAST(decision_date_alt AS date)         AS decision_date_alt
    , CAST(document_date AS date)             AS document_date
    , CAST(decision_number_alt AS string)     AS decision_number_alt
    , CAST(document_number AS string)         AS document_number
    , CAST(transaction_office_name AS string) AS transaction_office_name
    , CAST(form_data_json AS string)          AS form_data_json
    , CAST(last_modified_at AS timestamp)     AS last_modified_at
    , CAST(last_modified_by AS int)           AS last_modified_by
    , CAST(deleted AS int)                    AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_transaction_office') }}