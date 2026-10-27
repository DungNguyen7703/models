/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_related_person
* Program name: Staging SCMS.SC_FIRM_RELATED_PERSON
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
    , CAST(entity_type AS string)            AS entity_type
    , CAST(full_name AS string)              AS full_name
    , CAST(identification_number AS string)  AS identification_number
    , CAST(relationship AS string)           AS relationship
    , CAST(ownership_ratio AS decimal(12,4)) AS ownership_ratio
    , CAST(record_status AS int)             AS record_status
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(representative_title AS string)   AS representative_title
    , CAST(position_id AS string)            AS position_id
    , CAST(founding_shareholder AS int)      AS founding_shareholder
    , CAST(permanent_address AS string)      AS permanent_address
    , CAST(phone AS string)                  AS phone
    , CAST(workplace AS string)              AS workplace
    , CAST(email AS string)                  AS email
    , CAST(note AS string)                   AS note
    , CAST(gender AS int)                    AS gender
    , CAST(appointment_date AS date)         AS appointment_date
    , CAST(issue_date AS date)               AS issue_date
    , CAST(last_modified_at AS timestamp)    AS last_modified_at
    , CAST(ownership_ratio_date AS date)     AS ownership_ratio_date
    , CAST(date_of_birth AS date)            AS date_of_birth
    , CAST(legal_representative AS string)   AS legal_representative
    , CAST(created_by AS int)                AS created_by
    , CAST(issue_place AS string)            AS issue_place
    , CAST(country_id AS int)                AS country_id
    , CAST(shares_count AS int)              AS shares_count
    , CAST(org_name_en AS string)            AS org_name_en
    , CAST(org_short_name AS string)         AS org_short_name
    , CAST(transaction_time AS string)       AS transaction_time
    , CAST(resolution_number AS string)      AS resolution_number
    , CAST(transaction_content AS string)    AS transaction_content
    , CAST(relation_start_date AS date)      AS relation_start_date
    , CAST(relation_end_date AS date)        AS relation_end_date
    , CAST(deleted AS int)                   AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_related_person') }}