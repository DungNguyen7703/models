/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_inspection_conclusion_remedial
* Program name: Staging THANHTRA.INSPECTION_CONCLUSION_REMEDIAL
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                         AS id
    , CAST(inspection_conclusion_id AS string) AS inspection_conclusion_id
    , CAST(description AS string)              AS description
    , CAST(sort_order AS int)                  AS sort_order
    , CAST(created_at AS date)                 AS created_at
    , CAST(last_modified_at AS date)           AS last_modified_at
    , CAST(created_by AS string)               AS created_by
    , CAST(last_modified_by AS string)         AS last_modified_by
    , CAST(version AS bigint)                  AS version
    , CAST(deleted AS int)                     AS deleted
FROM {{ source('source_thanhtra', 'raw_inspection_conclusion_remedial') }}