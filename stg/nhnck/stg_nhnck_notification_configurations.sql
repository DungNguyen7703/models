/*
*--------------------------------------------------------------------*
* Program code: stg_nhnck_notification_configurations
* Program name: Staging NHNCK.NOTIFICATION_CONFIGURATIONS
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS int)                         AS id
    , CAST(type AS int)                     AS type
    , CAST(name AS string)                  AS name
    , CAST(trigger_event AS string)         AS trigger_event
    , CAST(action_type AS int)              AS action_type
    , CAST(is_noti AS int)                  AS is_noti
    , CAST(is_sms AS int)                   AS is_sms
    , CAST(is_email AS int)                 AS is_email
    , CAST(content_noti AS string)          AS content_noti
    , CAST(content_sms AS string)           AS content_sms
    , CAST(content_email AS string)         AS content_email
    , CAST(noti_parameters_json AS string)  AS noti_parameters_json
    , CAST(sms_parameters_json AS string)   AS sms_parameters_json
    , CAST(email_parameters_json AS string) AS email_parameters_json
    , CAST(receivers_json AS string)        AS receivers_json
FROM {{ source('source_nhnck', 'raw_notification_configurations') }}