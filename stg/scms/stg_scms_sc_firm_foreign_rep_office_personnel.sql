/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_foreign_rep_office_personnel
* Program name: Staging SCMS.SC_FIRM_FOREIGN_REP_OFFICE_PERSONNEL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                            AS id
    , CAST(sc_firm_foreign_rep_office_id AS int) AS sc_firm_foreign_rep_office_id
    , CAST(full_name AS string)                  AS full_name
    , CAST(national_id AS string)                AS national_id
    , CAST(id_issued_date AS date)               AS id_issued_date
    , CAST(issue_place AS string)                AS issue_place
    , CAST(permanent_address AS string)          AS permanent_address
    , CAST(nationality AS string)                AS nationality
    , CAST(email AS string)                      AS email
    , CAST(phone AS string)                      AS phone
    , CAST(position_json AS string)              AS position_json
    , CAST(rep_office_representative AS int)     AS rep_office_representative
    , CAST(appointment_date AS date)             AS appointment_date
    , CAST(dismissal_date AS date)               AS dismissal_date
    , CAST(record_status AS int)                 AS record_status
    , CAST(attachment_path AS string)            AS attachment_path
    , CAST(note AS string)                       AS note
    , CAST(created_by AS int)                    AS created_by
    , CAST(created_at AS timestamp)              AS created_at
    , CAST(last_modified_by AS int)              AS last_modified_by
    , CAST(last_modified_at AS timestamp)        AS last_modified_at
    , CAST(date_of_birth AS date)                AS date_of_birth
    , CAST(deleted AS int)                       AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_foreign_rep_office_personnel') }}