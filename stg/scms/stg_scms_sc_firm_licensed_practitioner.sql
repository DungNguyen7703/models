/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_licensed_practitioner
* Program name: Staging SCMS.SC_FIRM_LICENSED_PRACTITIONER
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                                AS id
    , CAST(sc_firm_info_id AS int)                   AS sc_firm_info_id
    , CAST(sc_firm_personnel_id AS int)              AS sc_firm_personnel_id
    , CAST(securities_license_number AS string)      AS securities_license_number
    , CAST(securities_license_date AS date)          AS securities_license_date
    , CAST(synced AS int)                            AS synced
    , CAST(sync_at AS timestamp)                     AS sync_at
    , CAST(note AS string)                           AS note
    , CAST(created_by AS int)                        AS created_by
    , CAST(created_at AS timestamp)                  AS created_at
    , CAST(record_status AS string)                  AS record_status
    , CAST(sc_firm_service_id AS int)                AS sc_firm_service_id
    , CAST(full_name_legacy AS string)               AS full_name_legacy
    , CAST(date_of_birth AS date)                    AS date_of_birth
    , CAST(national_id_legacy AS string)             AS national_id_legacy
    , CAST(id_card_issued_date AS date)              AS id_card_issued_date
    , CAST(issue_place_legacy AS string)             AS issue_place_legacy
    , CAST(nationality_legacy AS string)             AS nationality_legacy
    , CAST(permanent_address_legacy AS string)       AS permanent_address_legacy
    , CAST(permanent_residence AS string)            AS permanent_residence
    , CAST(birth_place AS string)                    AS birth_place
    , CAST(phone_legacy AS string)                   AS phone_legacy
    , CAST(mobile AS string)                         AS mobile
    , CAST(email AS string)                          AS email
    , CAST(company_name AS string)                   AS company_name
    , CAST(english_name AS string)                   AS english_name
    , CAST(short_name AS string)                     AS short_name
    , CAST(license_number AS string)                 AS license_number
    , CAST(department_legacy AS string)              AS department_legacy
    , CAST(position_legacy AS string)                AS position_legacy
    , CAST(start_date AS date)                       AS start_date
    , CAST(end_date AS date)                         AS end_date
    , CAST(record_status_alt AS string)              AS record_status_alt
    , CAST(errtext AS string)                        AS errtext
    , CAST(report_id AS int)                         AS report_id
    , CAST(datecreated AS date)                      AS datecreated
    , CAST(createdby AS string)                      AS createdby
    , CAST(datemodify AS date)                       AS datemodify
    , CAST(modifyby AS string)                       AS modifyby
    , CAST(batchid AS string)                        AS batchid
    , CAST(content AS string)                        AS content
    , CAST(nhn_id AS int)                            AS nhn_id
    , CAST(deleted AS int)                           AS deleted
    , CAST(gender_legacy AS string)                  AS gender_legacy
    , CAST(sc_firm_branch_id AS int)                 AS sc_firm_branch_id
    , CAST(sc_firm_transaction_office_id AS int)     AS sc_firm_transaction_office_id
    , CAST(sc_firm_rep_office_id AS int)             AS sc_firm_rep_office_id
    , CAST(business_line_id AS string)               AS business_line_id
    , CAST(labor_contract_termination_report AS int) AS labor_contract_termination_report
    , CAST(business_division_id AS int)              AS business_division_id
    , CAST(national_id AS string)                    AS national_id
    , CAST(position_ids AS string)                   AS position_ids
    , CAST(permanent_address AS string)              AS permanent_address
    , CAST(responsible_service_id AS int)            AS responsible_service_id
    , CAST(phone AS string)                          AS phone
    , CAST(entity_type AS string)                    AS entity_type
    , CAST(attachment_path AS string)                AS attachment_path
    , CAST(gender AS int)                            AS gender
    , CAST(full_name AS string)                      AS full_name
    , CAST(insider AS int)                           AS insider
    , CAST(work_start_date AS date)                  AS work_start_date
    , CAST(appointment_date AS date)                 AS appointment_date
    , CAST(issue_date AS date)                       AS issue_date
    , CAST(last_modified_at AS timestamp)            AS last_modified_at
    , CAST(work_end_date AS date)                    AS work_end_date
    , CAST(dismissal_date AS date)                   AS dismissal_date
    , CAST(date_of_birth_alt AS date)                AS date_of_birth_alt
    , CAST(last_modified_by AS int)                  AS last_modified_by
    , CAST(issue_place AS string)                    AS issue_place
    , CAST(department AS string)                     AS department
    , CAST(nationality_id AS int)                    AS nationality_id
    , CAST(securities_license_number_alt AS string)  AS securities_license_number_alt
    , CAST(latest_verification_at AS timestamp)      AS latest_verification_at
    , CAST(work_status AS string)                    AS work_status
    , CAST(verification_status AS int)               AS verification_status
    , CAST(mismatch_reason AS string)                AS mismatch_reason
FROM {{ source('source_scms', 'raw_sc_firm_licensed_practitioner') }}