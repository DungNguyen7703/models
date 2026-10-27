/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_inspection_report_outline
* Program name: Staging THANHTRA.INSPECTION_REPORT_OUTLINE
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                 AS id
    , CAST(title AS string)            AS title
    , CAST(period_type AS string)      AS period_type
    , CAST(period_value AS int)        AS period_value
    , CAST(report_year AS int)         AS report_year
    , CAST(note AS string)             AS note
    , CAST(created_at AS date)         AS created_at
    , CAST(last_modified_at AS date)   AS last_modified_at
    , CAST(created_by AS string)       AS created_by
    , CAST(last_modified_by AS string) AS last_modified_by
    , CAST(version AS bigint)          AS version
    , CAST(deleted AS int)             AS deleted
FROM {{ source('source_thanhtra', 'raw_inspection_report_outline') }}