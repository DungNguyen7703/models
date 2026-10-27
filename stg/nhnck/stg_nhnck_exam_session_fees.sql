/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_exam_session_fees
* Program name: Staging NHNCK.EXAM_SESSION_FEES
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                     AS id
    , CAST(exam_session_id AS int)      AS exam_session_id
    , CAST(certificate_id AS int)       AS certificate_id
    , CAST(fee_exam AS decimal(18,2))   AS fee_exam
    , CAST(fee_appeal AS decimal(18,2)) AS fee_appeal
    , CAST(status AS int)               AS status
    , CAST(created_at AS date)          AS created_at
    , CAST(updated_at AS date)          AS updated_at
    , CAST(created_by AS int)           AS created_by
    , CAST(updated_by AS int)           AS updated_by
FROM {{ source('source_nhnck', 'raw_exam_session_fees') }}