/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_insider_relation
* Program name: Staging SCMS.SC_FIRM_INSIDER_RELATION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-18		tuan.nguyenvanb		Cap nhat cot theo SCMS_UAT_schema.
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                           AS id
    , CAST(sc_firm_info_id AS int)              AS sc_firm_info_id
    , CAST(senior_personnel_id AS int)          AS senior_personnel_id
    , CAST(full_name AS string)                 AS full_name
    , CAST(national_id AS string)               AS national_id
    , CAST(relationship AS string)              AS relationship
    , CAST(ownership_ratio AS decimal(12,4))    AS ownership_ratio
    , CAST(record_status AS int)                AS record_status
    , CAST(created_at AS timestamp)             AS created_at
    , CAST(created_by AS int)                   AS created_by
    , CAST(founding_shareholder AS int)         AS founding_shareholder
    , CAST(permanent_address AS string)         AS permanent_address
    , CAST(phone AS string)                     AS phone
    , CAST(email AS string)                     AS email
    , CAST(note AS string)                      AS note
    , CAST(gender AS int)                       AS gender
    , CAST(relation_start_date AS date)         AS relation_start_date
    , CAST(issue_date AS date)                  AS issue_date
    , CAST(last_modified_at AS timestamp)       AS last_modified_at
    , CAST(ownership_ratio_date AS date)        AS ownership_ratio_date
    , CAST(date_of_birth AS date)               AS date_of_birth
    , CAST(issue_place AS string)               AS issue_place
    , CAST(nationality_id AS int)               AS nationality_id
    , CAST(shares_count AS int)                 AS shares_count
    , CAST(last_modified_by AS int)             AS last_modified_by
    , CAST(entity_type AS string)               AS entity_type
    , CAST(name_en AS string)                   AS name_en
    , CAST(short_name AS string)                AS short_name
    , CAST(legal_representative_name AS string) AS legal_representative_name
    , CAST(representative_position AS string)   AS representative_position
    , CAST(deleted AS int)                      AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_insider_relation') }}