/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_conversion_practice_history_confirms
* Program name: Staging NHNCK.CONVERSION_PRACTICE_HISTORY_CONFIRMS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                      AS id
    , CAST(request_id AS string)         AS request_id
    , CAST(conversion_request_id AS int) AS conversion_request_id
    , CAST(source_type AS int)           AS source_type
    , CAST(organization_id AS int)       AS organization_id
    , CAST(identity_number AS string)    AS identity_number
    , CAST(full_name AS string)          AS full_name
    , CAST(declared_work_history AS string) AS declared_work_history
    , CAST(status AS int)                AS status
    , CAST(result AS string)             AS result
    , CAST(responded_by AS string)       AS responded_by
    , CAST(responded_at AS date)         AS responded_at
    , CAST(corrected_work_history AS string) AS corrected_work_history
    , CAST(reason AS string)             AS reason
    , CAST(requested_by AS string)       AS requested_by
    , CAST(requested_at AS date)         AS requested_at
    , CAST(created_by AS int)            AS created_by
    , CAST(created_at AS date)           AS created_at
    , CAST(updated_by AS int)            AS updated_by
    , CAST(updated_at AS date)           AS updated_at
FROM {{ source('source_nhnck', 'raw_conversion_practice_history_confirms') }}
