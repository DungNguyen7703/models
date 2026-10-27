/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_major_shareholder_relation
* Program name: Staging SCMS.SC_FIRM_MAJOR_SHAREHOLDER_RELATION
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
    , CAST(individual AS int)                    AS individual
    , CAST(shareholder_id AS int)                AS shareholder_id
    , CAST(sc_firm_info_id AS int)               AS sc_firm_info_id
    , CAST(address AS string)                    AS address
    , CAST(phone AS string)                      AS phone
    , CAST(email AS string)                      AS email
    , CAST(note AS string)                       AS note
    , CAST(full_name AS string)                  AS full_name
    , CAST(relationship AS string)               AS relationship
    , CAST(relation_start_date AS date)          AS relation_start_date
    , CAST(issue_date AS date)                   AS issue_date
    , CAST(last_modified_at AS timestamp)        AS last_modified_at
    , CAST(large_shareholder_date AS date)       AS large_shareholder_date
    , CAST(relation_end_date AS date)            AS relation_end_date
    , CAST(created_at AS timestamp)              AS created_at
    , CAST(issue_place AS string)                AS issue_place
    , CAST(nationality_id AS int)                AS nationality_id
    , CAST(identification_number AS string)      AS identification_number
    , CAST(shares_count AS int)                  AS shares_count
    , CAST(ownership_ratio AS decimal(12,4))     AS ownership_ratio
    , CAST(contributed_capital AS decimal(22,4)) AS contributed_capital
    , CAST(deleted AS int)                       AS deleted
    , CAST(created_by AS decimal(19,0))          AS created_by
    , CAST(last_modified_by AS decimal(19,0))    AS last_modified_by
FROM {{ source('source_scms', 'raw_sc_firm_major_shareholder_relation') }}