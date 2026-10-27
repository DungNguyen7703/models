/*
*--------------------------------------------------------------------*
* Program code: stg_thanhtra_petition
* Program name: Staging THANHTRA.PETITION
* Created by:
* Created date:
*--------------------------------------------------------------------*
* Modified management
* Date				User				Description
*
*--------------------------------------------------------------------*
*/

SELECT
    CAST(id AS string)                            AS id
    , CAST(code AS string)                        AS code
    , CAST(received_date AS date)                 AS received_date
    , CAST(forwarding_unit AS string)             AS forwarding_unit
    , CAST(sender_name AS string)                 AS sender_name
    , CAST(sender_address AS string)              AS sender_address
    , CAST(content AS string)                     AS content
    , CAST(petition_category AS string)           AS petition_category
    , CAST(related_to_corporate_bond AS int)      AS related_to_corporate_bond
    , CAST(eligible_for_processing AS int)        AS eligible_for_processing
    , CAST(within_jurisdiction AS int)            AS within_jurisdiction
    , CAST(assigned_officer_id AS string)         AS assigned_officer_id
    , CAST(assigned_officer_name AS string)       AS assigned_officer_name
    , CAST(duplicate_type AS string)              AS duplicate_type
    , CAST(original_petition_id AS string)        AS original_petition_id
    , CAST(submission_number AS string)           AS submission_number
    , CAST(transferred_authority AS string)       AS transferred_authority
    , CAST(internal_transfer_unit_id AS string)   AS internal_transfer_unit_id
    , CAST(internal_transfer_unit_name AS string) AS internal_transfer_unit_name
    , CAST(archived AS int)                       AS archived
    , CAST(guidance_document_number AS string)    AS guidance_document_number
    , CAST(guidance_document_date AS date)        AS guidance_document_date
    , CAST(status AS string)                      AS status
    , CAST(note AS string)                        AS note
    , CAST(end_date AS date)                      AS end_date
    , CAST(created_at AS date)                    AS created_at
    , CAST(last_modified_at AS date)              AS last_modified_at
    , CAST(created_by AS string)                  AS created_by
    , CAST(last_modified_by AS string)            AS last_modified_by
    , CAST(version AS bigint)                     AS version
    , CAST(deleted AS int)                        AS deleted
    , CAST(target_type AS string)                 AS target_type
    , CAST(target_reference_id AS string)         AS target_reference_id
    , CAST(target_name AS string)                 AS target_name
FROM {{ source('source_thanhtra', 'raw_petition') }}