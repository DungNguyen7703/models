/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_professional_relationships
* Program name: Staging NHNCK.PROFESSIONAL_RELATIONSHIPS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                  AS id
    , CAST(professional_id AS int)   AS professional_id
    , CAST(relationship_type AS int) AS relationship_type
    , CAST(full_name AS string)      AS full_name
    , CAST(birth_year AS int)        AS birth_year
    , CAST(address AS string)        AS address
    , CAST(occupation AS string)     AS occupation
    , CAST(workplace AS string)      AS workplace
    , CAST(note AS string)           AS note
    , CAST(created_at AS date)       AS created_at
    , CAST(country_id AS int)        AS country_id
    , CAST(identity_id AS string)    AS identity_id
    , CAST(updated_at AS date)       AS updated_at
    , CAST(created_by AS int)        AS created_by
    , CAST(updated_by AS int)        AS updated_by
FROM {{ source('source_nhnck', 'raw_professional_relationships') }}