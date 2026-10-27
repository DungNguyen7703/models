/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_application_decisions
* Program name: Staging NHNCK.APPLICATION_DECISIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)               AS id
    , CAST(application_id AS int) AS application_id
    , CAST(decision_id AS int)    AS decision_id
FROM {{ source('source_nhnck', 'raw_application_decisions') }}