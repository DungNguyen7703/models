/*
*--------------------------------------------------------------------*
* Program code: stg_scms_form_indicator_input
* Program name: Staging SCMS.FORM_INDICATOR_INPUT
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS decimal(19,0))                     AS id
    , CAST(code AS string)                        AS code
    , CAST(item_name AS string)                   AS item_name
    , CAST(description AS string)                 AS description
    , CAST(data_type AS string)                   AS data_type
    , CAST(reference_catalog_id AS decimal(19,0)) AS reference_catalog_id
    , CAST(record_status AS int)                  AS record_status
    , CAST(created_by AS string)                  AS created_by
    , CAST(updated_by AS string)                  AS updated_by
    , CAST(created_at AS timestamp)               AS created_at
    , CAST(last_modified_at AS timestamp)         AS last_modified_at
    , CAST(reference_catalog_type AS string)      AS reference_catalog_type
    , CAST(category AS string)                    AS category
    , CAST(source_entity_code AS string)          AS source_entity_code
    , CAST(field_metadata_id AS decimal(19,0))    AS field_metadata_id
    , CAST(selection_list_source AS string)       AS selection_list_source
FROM {{ source('source_scms', 'raw_form_indicator_input') }}