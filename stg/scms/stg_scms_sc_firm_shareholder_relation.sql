/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_shareholder_relation
* Program name: Staging SCMS.SC_FIRM_SHAREHOLDER_RELATION
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
    , CAST(sc_firm_shareholder_id AS int)    AS sc_firm_shareholder_id
    , CAST(full_name AS string)              AS full_name
    , CAST(relationship AS string)           AS relationship
    , CAST(id_number AS string)              AS id_number
    , CAST(issue_date AS date)               AS issue_date
    , CAST(issue_place AS string)            AS issue_place
    , CAST(workplace AS string)              AS workplace
    , CAST(job_title AS string)              AS job_title
    , CAST(sc_firm_with_shares_id AS int)    AS sc_firm_with_shares_id
    , CAST(shares_count AS int)              AS shares_count
    , CAST(ownership_ratio AS decimal(10,4)) AS ownership_ratio
    , CAST(attachment_path AS string)        AS attachment_path
    , CAST(note AS string)                   AS note
    , CAST(created_by AS int)                AS created_by
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(last_modified_by AS int)          AS last_modified_by
    , CAST(last_modified_at AS timestamp)    AS last_modified_at
    , CAST(record_status AS int)             AS record_status
    , CAST(deleted AS int)                   AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_shareholder_relation') }}