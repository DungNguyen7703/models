/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_examination_result_notice_remedial
* Program name: Staging THANHTRA.EXAMINATION_RESULT_NOTICE_REMEDIAL
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
    , CAST(examination_result_notice_id AS string) AS examination_result_notice_id
    , CAST(description AS string)                  AS description
    , CAST(sort_order AS int)                      AS sort_order
    , CAST(created_at AS date)                     AS created_at
    , CAST(last_modified_at AS date)               AS last_modified_at
    , CAST(created_by AS string)                   AS created_by
    , CAST(last_modified_by AS string)             AS last_modified_by
    , CAST(version AS bigint)                      AS version
    , CAST(deleted AS int)                         AS deleted
FROM {{ source('source_thanhtra', 'raw_examination_result_notice_remedial') }}