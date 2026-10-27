/*
*--------------------------------------------------------------------*
* Program code: atm_sp_license_decision_document_x_sp_license_application_relationship
* Program name: Atomic Securities Practitioner License Decision Document X Securities Practitioner License Application Relationship
* Created by: tuan.nguyenvanb
* Created date: 2026-10-05
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
* 2026-10-05		tuan.nguyenvanb		[MOI] Tao model theo LLD NHNCK_APPLICATION_DECISIONS.
*--------------------------------------------------------------------*
*/

WITH ap_de AS (
    SELECT
        id
        , application_id
        , decision_id
    FROM {{ ref('ods_nhnck_application_decisions') }}
),

appl AS (
    SELECT
        id
        , application_code
    FROM {{ ref('ods_nhnck_applications') }}
)

SELECT
    CAST('NHNCK_APPLICATION_DECISIONS' AS string)                                      AS src_stm_code
    , {{ generate_surrogate_key_bigint('NHNCK_DECISIONS', "ap_de.decision_id") }}        AS sp_license_decision_document_id
    , CAST(ap_de.decision_id AS string)                                                  AS sp_license_decision_document_code
    , {{ generate_surrogate_key_bigint('NHNCK_APPLICATIONS', "appl.application_code") }} AS sp_license_application_id
    , CAST(appl.application_code AS string)                                               AS sp_license_application_code
FROM ap_de
    LEFT JOIN appl ON ap_de.APPLICATION_ID = appl.ID