/*
*--------------------------------------------------------------------*
* Program code: stg_scms_sc_firm_domestic_rep_office
* Program name: Staging SCMS.SC_FIRM_DOMESTIC_REP_OFFICE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                           AS id
    , CAST(rep_office_name AS string)         AS rep_office_name
    , CAST(office_address AS string)          AS office_address
    , CAST(office_business_license AS string) AS office_business_license
    , CAST(office_license_date AS date)       AS office_license_date
    , CAST(head_representative AS string)     AS head_representative
    , CAST(nationality_id AS int)             AS nationality_id
    , CAST(note AS string)                    AS note
    , CAST(created_by AS int)                 AS created_by
    , CAST(created_at AS timestamp)           AS created_at
    , CAST(last_modified_by AS int)           AS last_modified_by
    , CAST(last_modified_at AS timestamp)     AS last_modified_at
    , CAST(sc_firm_info_id AS int)            AS sc_firm_info_id
FROM {{ source('source_scms', 'raw_sc_firm_domestic_rep_office') }}