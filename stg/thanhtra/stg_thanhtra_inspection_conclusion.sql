/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_inspection_conclusion
* Program name: Staging THANHTRA.INSPECTION_CONCLUSION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                             AS id
    , CAST(inspection_team_id AS string)           AS inspection_team_id
    , CAST(conclusion_number AS string)            AS conclusion_number
    , CAST(issued_date AS date)                    AS issued_date
    , CAST(announced_date AS date)                 AS announced_date
    , CAST(target_type AS string)                  AS target_type
    , CAST(target_reference_id AS string)          AS target_reference_id
    , CAST(target_name AS string)                  AS target_name
    , CAST(content AS string)                      AS content
    , CAST(government_inspector_sent_date AS date) AS government_inspector_sent_date
    , CAST(recommendation AS string)               AS recommendation
    , CAST(execution_status AS string)             AS execution_status
    , CAST(execution_description AS string)        AS execution_description
    , CAST(created_at AS date)                     AS created_at
    , CAST(last_modified_at AS date)               AS last_modified_at
    , CAST(created_by AS string)                   AS created_by
    , CAST(last_modified_by AS string)             AS last_modified_by
    , CAST(version AS bigint)                      AS version
    , CAST(deleted AS int)                         AS deleted
    , CAST(transferred AS int)                     AS transferred
FROM {{ source('source_thanhtra', 'raw_inspection_conclusion') }}