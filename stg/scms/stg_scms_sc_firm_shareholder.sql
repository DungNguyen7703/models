/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_shareholder
* Program name: Staging SCMS.SC_FIRM_SHAREHOLDER
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
    , CAST(sc_firm_info_id AS int)               AS sc_firm_info_id
    , CAST(shareholder_name AS string)           AS shareholder_name
    , CAST(individual AS int)                    AS individual
    , CAST(date_of_birth AS date)                AS date_of_birth
    , CAST(place_of_birth AS string)             AS place_of_birth
    , CAST(id_number AS string)                  AS id_number
    , CAST(issue_date AS date)                   AS issue_date
    , CAST(issue_place AS string)                AS issue_place
    , CAST(nationality_id AS int)                AS nationality_id
    , CAST(current_address AS string)            AS current_address
    , CAST(household_registration AS string)     AS household_registration
    , CAST(party_member AS int)                  AS party_member
    , CAST(education_level AS string)            AS education_level
    , CAST(occupation AS string)                 AS occupation
    , CAST(degree AS string)                     AS degree
    , CAST(legal_entity_representative AS int)   AS legal_entity_representative
    , CAST(workplace AS string)                  AS workplace
    , CAST(job_title AS string)                  AS job_title
    , CAST(company_employee AS int)              AS company_employee
    , CAST(trading_account AS string)            AS trading_account
    , CAST(shareholder_type AS string)           AS shareholder_type
    , CAST(shares_held AS int)                   AS shares_held
    , CAST(ownership_ratio AS decimal(10,4))     AS ownership_ratio
    , CAST(large_shareholder_date AS date)       AS large_shareholder_date
    , CAST(note AS string)                       AS note
    , CAST(created_by AS int)                    AS created_by
    , CAST(created_at AS timestamp)              AS created_at
    , CAST(last_modified_by AS int)              AS last_modified_by
    , CAST(last_modified_at AS timestamp)        AS last_modified_at
    , CAST(record_status AS int)                 AS record_status
    , CAST(sc_firm_personnel_id AS int)          AS sc_firm_personnel_id
    , CAST(practitioner_legacy_id AS int)        AS practitioner_legacy_id
    , CAST(owner AS int)                         AS owner
    , CAST(founding_shareholder AS int)          AS founding_shareholder
    , CAST(phone AS string)                      AS phone
    , CAST(email AS string)                      AS email
    , CAST(shareholder_entity_type AS string)    AS shareholder_entity_type
    , CAST(foreign_investment AS int)            AS foreign_investment
    , CAST(contributed_capital AS decimal(22,4)) AS contributed_capital
    , CAST(controlling_shareholder AS string)    AS controlling_shareholder
    , CAST(freely_tradable_shares AS int)        AS freely_tradable_shares
    , CAST(pledged_shares AS int)                AS pledged_shares
    , CAST(restricted_shares AS int)             AS restricted_shares
    , CAST(org_short_name AS string)             AS org_short_name
    , CAST(legal_representative_name AS string)  AS legal_representative_name
    , CAST(representative_position AS string)    AS representative_position
    , CAST(deleted AS int)                       AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_shareholder') }}