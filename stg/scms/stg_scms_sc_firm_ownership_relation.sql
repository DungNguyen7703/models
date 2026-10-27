/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_ownership_relation
* Program name: Staging SCMS.SC_FIRM_OWNERSHIP_RELATION
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
    , CAST(registered_address AS string)     AS registered_address
    , CAST(note AS string)                   AS note
    , CAST(enterprise_type_id AS int)        AS enterprise_type_id
    , CAST(relation_type AS string)          AS relation_type
    , CAST(enterprise_code AS string)        AS enterprise_code
    , CAST(last_modified_at AS timestamp)    AS last_modified_at
    , CAST(end_date AS date)                 AS end_date
    , CAST(ownership_date AS date)           AS ownership_date
    , CAST(created_at AS timestamp)          AS created_at
    , CAST(last_modified_by AS int)          AS last_modified_by
    , CAST(created_by AS int)                AS created_by
    , CAST(country_id AS int)                AS country_id
    , CAST(company_name AS string)           AS company_name
    , CAST(ownership_ratio AS decimal(10,2)) AS ownership_ratio
    , CAST(deleted AS int)                   AS deleted
FROM {{ source('source_scms', 'raw_sc_firm_ownership_relation') }}